import json
import threading
import time
import pika

from .config import settings
from .database import SessionLocal
from .logging_config import setup_logger

logger = setup_logger(settings.service_name, settings.log_level)

EXCHANGE_NAME = "polaris.events"
QUEUE_RESULTS = "observation.verification_results"


class RabbitMQClient:
    def __init__(self):
        self._connection = None
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
            channel = self._connection.channel()
            channel.exchange_declare(exchange=EXCHANGE_NAME, exchange_type="topic", durable=True)
            return self._connection

    def publish_observation_submitted(self, message: dict):
        try:
            conn = self.get_connection()
            channel = conn.channel()
            channel.basic_publish(
                exchange=EXCHANGE_NAME,
                routing_key="observation.submitted",
                body=json.dumps(message),
                properties=pika.BasicProperties(
                    delivery_mode=2,
                    content_type="application/json",
                ),
            )
            logger.info(f"Published 'observation.submitted': {message}")
        except Exception as e:
            logger.error(f"Failed to publish 'observation.submitted' to RabbitMQ: {e}")


mq_client = RabbitMQClient()


def start_verification_consumer(update_callback):
    """Start background thread consuming verification results."""
    def consume_loop():
        while True:
            try:
                logger.info(f"Connecting to RabbitMQ at {settings.rabbitmq_host}:{settings.rabbitmq_port} for results consumer...")
                params = pika.ConnectionParameters(
                    host=settings.rabbitmq_host,
                    port=settings.rabbitmq_port,
                    credentials=pika.PlainCredentials(settings.rabbitmq_user, settings.rabbitmq_password),
                    heartbeat=60,
                )
                connection = pika.BlockingConnection(params)
                channel = connection.channel()
                channel.exchange_declare(exchange=EXCHANGE_NAME, exchange_type="topic", durable=True)
                channel.queue_declare(queue=QUEUE_RESULTS, durable=True)

                # Bind to both verified and rejected events
                channel.queue_bind(queue=QUEUE_RESULTS, exchange=EXCHANGE_NAME, routing_key="observation.verified")
                channel.queue_bind(queue=QUEUE_RESULTS, exchange=EXCHANGE_NAME, routing_key="observation.rejected")

                def on_message(ch, method, properties, body):
                    try:
                        data = json.loads(body.decode("utf-8"))
                        logger.info(f"Received verification result event ({method.routing_key}): {data}")
                        with SessionLocal() as db:
                            update_callback(db, data)
                        ch.basic_ack(delivery_tag=method.delivery_tag)
                    except Exception as exc:
                        logger.error(f"Error handling verification result: {exc}", exc_info=True)
                        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

                channel.basic_qos(prefetch_count=1)
                channel.basic_consume(queue=QUEUE_RESULTS, on_message_callback=on_message)
                logger.info("Observation Service results consumer active.")
                channel.start_consuming()
            except Exception as e:
                logger.warning(f"Results consumer disconnected or unavailable: {e}. Retrying in 5 seconds...")
                time.sleep(5)

    thread = threading.Thread(target=consume_loop, daemon=True)
    thread.start()
