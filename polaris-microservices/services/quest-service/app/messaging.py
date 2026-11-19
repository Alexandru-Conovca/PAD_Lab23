import json
import threading
import time
import pika

from .config import settings
from .database import SessionLocal
from .logging_config import setup_logger

logger = setup_logger(settings.service_name, settings.log_level)

EXCHANGE_NAME = "polaris.events"
QUEUE_NAME = "quest.observation_verified"
ROUTING_KEY_VERIFIED = "observation.verified"


def start_observation_verified_consumer(verified_callback):
    """Start background thread consuming 'observation.verified' events to update quest progress."""
    def consume_loop():
        while True:
            try:
                logger.info(f"Connecting to RabbitMQ at {settings.rabbitmq_host}:{settings.rabbitmq_port} for Quest consumer...")
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
                channel.queue_bind(queue=QUEUE_NAME, exchange=EXCHANGE_NAME, routing_key=ROUTING_KEY_VERIFIED)

                def on_message(ch, method, properties, body):
                    try:
                        data = json.loads(body.decode("utf-8"))
                        logger.info(f"Quest Service received verified observation: {data}")
                        with SessionLocal() as db:
                            verified_callback(db, data)
                        ch.basic_ack(delivery_tag=method.delivery_tag)
                    except Exception as exc:
                        logger.error(f"Error handling quest verified observation: {exc}", exc_info=True)
                        ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)

                channel.basic_qos(prefetch_count=1)
                channel.basic_consume(queue=QUEUE_NAME, on_message_callback=on_message)
                logger.info("Quest Service consumer active and listening for verified observations.")
                channel.start_consuming()
            except Exception as e:
                logger.warning(f"Quest consumer disconnected or unavailable: {e}. Retrying in 5 seconds...")
                time.sleep(5)

    thread = threading.Thread(target=consume_loop, daemon=True)
    thread.start()
