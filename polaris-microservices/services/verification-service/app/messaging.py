import json
import threading
import time
from datetime import datetime
import pika

from .config import settings
from .database import SessionLocal
from .logging_config import setup_logger

logger = setup_logger(settings.service_name, settings.log_level)

EXCHANGE_NAME = "polaris.events"
QUEUE_NAME = "verification.observation_submitted"
ROUTING_KEY_SUBMITTED = "observation.submitted"


class RabbitMQClient:
    def __init__(self):
        self._connection = None
        self._channel = None
        self._lock = threading.Lock()

    def get_connection(self):
        with self._lock:
            if self._connection and self._connection.is_open:
                return self._connection
            params = pika.ConnectionParameters(
                host=settings.rabbitmq_host,
                port=settings.rabbitmq_port,
                credentials=pika.PlainCredentials(settings.rabbitmq_user, settings.rabbitmq_password),
                heartbeat=60,
                blocked_connection_timeout=300,
            )
            self._connection = pika.BlockingConnection(params)
            self._channel = self._connection.channel()
            self._channel.exchange_declare(exchange=EXCHANGE_NAME, exchange_type="topic", durable=True)
            return self._connection

    def publish_event(self, routing_key: str, message: dict):
        try:
            conn = self.get_connection()
            channel = conn.channel()
            channel.basic_publish(
                exchange=EXCHANGE_NAME,
                routing_key=routing_key,
                body=json.dumps(message),
                properties=pika.BasicProperties(
                    delivery_mode=2,  # make message persistent
                    content_type="application/json",
                ),
            )
            logger.info(f"Published event '{routing_key}': {message}")
        except Exception as e:
            logger.error(f"Failed to publish event to RabbitMQ ({routing_key}): {e}")


mq_client = RabbitMQClient()


def start_consumer(verify_callback):
    """Start background thread consuming 'observation.submitted' events."""
    def consume_loop():
        while True:
            try:
                logger.info(f"Connecting to RabbitMQ at {settings.rabbitmq_host}:{settings.rabbitmq_port} for verification consumer...")
                params = pika.ConnectionParameters(
                    host=settings.rabbitmq_host,
                    port=settings.rabbitmq_port,
                    credentials=pika.PlainCredentials(settings.rabbitmq_user, settings.rabbitmq_password),
                    heartbeat=60,
                )
                connection = pika.BlockingConnection(params)
                channel = connection.channel()
                channel.exchange_declare(exchange=EXCHANGE_NAME, exchange_type="topic", durable=True)
                channel.queue_declare(queue=QUEUE_NAME, durable=True)
                channel.queue_bind(queue=QUEUE_NAME, exchange=EXCHANGE_NAME, routing_key=ROUTING_KEY_SUBMITTED)

                def on_message(ch, method, properties, body):
                    try:
                        data = json.loads(body.decode("utf-8"))
                        logger.info(f"Received observation submission event: {data}")
                        with SessionLocal() as db:
                            verify_callback(db, data)
                        ch.basic_ack(delivery_tag=method.delivery_tag)
                    except Exception as exc:
                        logger.error(f"Error processing message: {exc}", exc_info=True)
                        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

                channel.basic_qos(prefetch_count=1)
                channel.basic_consume(queue=QUEUE_NAME, on_message_callback=on_message)
                logger.info("Verification RabbitMQ consumer active and listening for observations.")
                channel.start_consuming()
            except Exception as e:
                logger.warning(f"RabbitMQ consumer disconnected or unavailable: {e}. Retrying in 5 seconds...")
                time.sleep(5)

    thread = threading.Thread(target=consume_loop, daemon=True)
    thread.start()
