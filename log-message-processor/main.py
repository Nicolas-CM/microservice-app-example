import time
import redis
import os
import json
import requests
from py_zipkin.zipkin import zipkin_span, ZipkinAttrs, generate_random_64bit_string
import time
import random
from threading import Thread
from http.server import HTTPServer, BaseHTTPRequestHandler

def log_message(message):
    time_delay = random.randrange(0, 2000)
    time.sleep(time_delay / 1000)
    print('message received after waiting for {}ms: {}'.format(time_delay, message))

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "healthy"}')
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        # Silenciar logs de HTTP server
        pass

def start_health_server():
    port = int(os.environ.get('PORT', 80))
    server = HTTPServer(('', port), HealthHandler)
    print(f'Health server running on port {port}')
    server.serve_forever()

if __name__ == '__main__':
    print('Iniciando log-message-processor...')
    
    # Iniciar servidor de salud en un hilo separado
    health_thread = Thread(target=start_health_server, daemon=True)
    health_thread.start()
    
    # Obtener configuración desde variables de entorno
    redis_host = os.environ.get('REDIS_HOST', 'localhost')
    redis_port = int(os.environ.get('REDIS_PORT', 6379))
    redis_channel = os.environ.get('REDIS_CHANNEL', 'log_channel')
    redis_password = os.environ.get('REDIS_PASSWORD', '')
    zipkin_url = os.environ.get('ZIPKIN_URL', '')
    
    print(f'Configuración Redis: host={redis_host}, port={redis_port}, channel={redis_channel}')
    
    def http_transport(encoded_span):
        try:
            requests.post(
                zipkin_url,
                data=encoded_span,
                headers={'Content-Type': 'application/x-thrift'},
            )
        except Exception as e:
            print(f'Error sending to Zipkin: {e}')

    
    import time
    # Configuración de Redis con contraseña
    redis_client = redis.Redis(
        host=redis_host,
        port=redis_port,
        password=redis_password if redis_password else None,
        decode_responses=True,
        db=0,
        socket_connect_timeout=5,
        socket_timeout=5
    )

    # Reintentos de conexión a Redis (más robusto)
    max_retries = 30
    wait_seconds = 3
    redis_connected = False
    
    for attempt in range(max_retries):
        try:
            redis_client.ping()
            print('Successfully connected to Redis!')
            print('Esperando mensajes en el canal:', redis_channel)
            redis_connected = True
            break
        except Exception as e:
            print(f'Intento {attempt+1}/{max_retries} - Failed to connect to Redis: {e}')
            if attempt < max_retries - 1:
                time.sleep(wait_seconds)
    
    if not redis_connected:
        print('No se pudo conectar a Redis después de varios intentos. Continuando sin Redis...')
        # En lugar de salir, mantener el contenedor vivo con solo el health server
        try:
            while True:
                time.sleep(60)
                print('Log processor running without Redis connection...')
        except KeyboardInterrupt:
            print("Process stopped by user")
        exit(0)
        
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
    except Exception as e:
        print(f"Error en el procesamiento principal: {e}")
        # Mantener el contenedor vivo incluso si hay errores
        try:
            while True:
                time.sleep(60)
                print('Log processor running with errors...')
        except KeyboardInterrupt:
            print("Process stopped by user")




