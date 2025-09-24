import time
import redis
import os
import json
import requests
from py_zipkin.zipkin import zipkin_span, ZipkinAttrs, generate_random_64bit_string
import time
import random

def log_message(message):
    time_delay = random.randrange(0, 2000)
    time.sleep(time_delay / 1000)
    print('message received after waiting for {}ms: {}'.format(time_delay, message))

if __name__ == '__main__':
    print('Iniciando log-message-processor...')
    # Hardcode para depuración
    redis_host = "redis"
    redis_port = 6379
    redis_channel = "log_channel"
    redis_password = "miclave123"
    zipkin_url = os.environ['ZIPKIN_URL'] if 'ZIPKIN_URL' in os.environ else ''
    def http_transport(encoded_span):
        requests.post(
            zipkin_url,
            data=encoded_span,
            headers={'Content-Type': 'application/x-thrift'},
        )

    import time
    # Configuración de Redis con contraseña
    redis_client = redis.Redis(
        host=redis_host,
        port=redis_port,
        password=redis_password,
        decode_responses=True,
        db=0
    )

    # Reintentos de conexión a Redis (más robusto)
    max_retries = 30
    wait_seconds = 3
    for attempt in range(max_retries):
        try:
            redis_client.ping()
            print('Successfully connected to Redis!')
            print('Esperando mensajes en el canal:', redis_channel)
            break
        except Exception as e:
            print(f'Intento {attempt+1}/{max_retries} - Failed to connect to Redis: {e}')
            time.sleep(wait_seconds)
    else:
        print('No se pudo conectar a Redis después de varios intentos. Saliendo...')
        exit(1)
        
    pubsub = redis_client.pubsub()
    pubsub.subscribe([redis_channel])
    print(f'Subscribed to channel: {redis_channel}')
    try:
        for item in pubsub.listen():
            data = item['data']
            # Ignorar mensajes de tipo entero (suscripción) o que no sean bytes
            if isinstance(data, int):
                continue
            try:
                decoded = data.decode("utf-8")
                print(f"Mensaje recibido bruto: {decoded}")
                message = json.loads(decoded)
            except Exception as e:
                print(f"[DEBUG] No es JSON válido o error: {e}")
                print(f"[DEBUG] Mensaje recibido bruto: {data}")
                continue

            if not zipkin_url or 'zipkinSpan' not in message:
                log_message(message)
                continue

            span_data = message['zipkinSpan']
            try:
                with zipkin_span(
                    service_name='log-message-processor',
                    zipkin_attrs=ZipkinAttrs(
                        trace_id=span_data['_traceId']['value'],
                        span_id=generate_random_64bit_string(),
                        parent_span_id=span_data['_spanId'],
                        is_sampled=span_data['_sampled']['value'],
                        flags=None
                    ),
                    span_name='save_log',
                    transport_handler=http_transport,
                    sample_rate=100
                ):
                    log_message(message)
            except Exception as e:
                print('did not send data to Zipkin: {}'.format(e))
                log_message(message)
    except KeyboardInterrupt:
        print("\nProceso detenido por el usuario (Ctrl+C). Cerrando log-message-processor...")




