# Microservice App Example

Proyecto de aplicación TODO distribuida, diseñada con arquitectura de microservicios y pensada para prácticas de DevOps, despliegue, integración y experimentación con diferentes lenguajes y tecnologías.

## Arquitectura General

La aplicación está compuesta por los siguientes microservicios:

- **Users API** (Java Spring Boot): Gestión de usuarios.
- **Auth API** (Go): Autenticación y generación de JWT.
- **TODOs API** (Node.js): CRUD de tareas y logging a Redis.
- **Log Message Processor** (Python): Procesador de logs desde Redis.
- **Frontend** (Vue.js): Interfaz de usuario.

![Arquitectura](/arch-img/Microservices.png)

## Estructura del Proyecto

```
├── auth-api/                # Microservicio de autenticación (Go)
├── todos-api/               # Microservicio de tareas (Node.js)
├── users-api/               # Microservicio de usuarios (Java Spring Boot)
├── log-message-processor/   # Procesador de logs (Python)
├── frontend/                # Aplicación web (Vue.js)
├── infra/                   # Infraestructura como código (Terraform)
├── docker-compose.yml       # Orquestación de servicios
└── README.md
```

## Orquestación y Ejecución Local

Todos los servicios pueden ser levantados fácilmente usando Docker Compose:

```bash
docker-compose up --build
```

Esto levantará:
- Frontend en `http://localhost:8080`
- Auth API en `http://localhost:8081`
- TODOs API en `http://localhost:8082`
- Users API en `http://localhost:8083`
- Redis en `localhost:6379`

Variables de entorno principales (ver `docker-compose.yml`):
- `JWT_SECRET`: Secreto compartido para JWT.
- `REDIS_HOST`, `REDIS_PORT`, `REDIS_CHANNEL`: Configuración de Redis.
- `AUTH_API_PORT`, `TODO_API_PORT`, `SERVER_PORT`: Puertos de los servicios.

## Resumen de Microservicios

### Users API (`/users-api`)
- **Tecnología:** Java + Spring Boot
- **Endpoints:** `/users`, `/users/:username`
- **Build:** `./mvnw clean install`
- **Run:** `JWT_SECRET=PRFT SERVER_PORT=8083 java -jar target/users-api-0.0.1-SNAPSHOT.jar`
- **Dependencias:** Java openJDK8

### Auth API (`/auth-api`)
- **Tecnología:** Go
- **Endpoint:** `/login`
- **Build:** `go build`
- **Run:** `AUTH_API_PORT=8000 USERS_API_ADDRESS=... JWT_SECRET=... ./auth-api`
- **Usuarios por defecto:** admin/admin, johnd/foo, janed/ddd
- **Dependencias:** Go 1.18.2

### TODOs API (`/todos-api`)
- **Tecnología:** Node.js
- **Endpoints:** `/todos` (GET, POST), `/todos/:taskId` (DELETE)
- **Build:** `npm install`
- **Run:** `JWT_SECRET=PRFT TODO_API_PORT=8082 npm start`
- **Dependencias:** Node 8.17.0, NPM 6.13.4

### Log Message Processor (`/log-message-processor`)
- **Tecnología:** Python
- **Función:** Consume mensajes de Redis y los imprime.
- **Build:** `pip3 install -r requirements.txt`
- **Run:** `REDIS_HOST=127.0.0.1 REDIS_PORT=6379 REDIS_CHANNEL=log_channel python3 main.py`
- **Dependencias:** Python 3.6, Redis 7.0

### Frontend (`/frontend`)
- **Tecnología:** Vue.js
- **Build:** `npm install && npm run build`
- **Run:** `PORT=8080 AUTH_API_ADDRESS=http://127.0.0.1:8000 TODOS_API_ADDRESS=http://127.0.0.1:8082 npm start`
- **Dependencias:** Node 8.17.0, NPM 6.13.4

## Infraestructura como Código (Terraform)

El directorio `infra/` contiene toda la definición de infraestructura para desplegar los microservicios en Azure usando Terraform:

- **Recursos principales:**
	- Resource Group
	- Azure Container Registry (ACR)
	- Redis Cache
	- App Services para cada microservicio y frontend
	- Autoscaling para TODOs API

- **Variables importantes:**
	- `project_name`, `environment`, `location`, `jwt_secret`, credenciales de Azure
	- Versiones de cada microservicio (por variable)

- **Backend remoto:**
	- El estado de Terraform se almacena en un Storage Account de Azure (ver `backend.conf`)

### Ejemplo de despliegue en Azure

1. Configura tus credenciales de Azure y variables en un archivo `.tfvars` o como variables de entorno.
2. Inicializa Terraform:
	 ```bash
	 cd infra
	 terraform init -backend-config=backend.conf
	 ```
3. Previsualiza los cambios:
	 ```bash
	 terraform plan -var-file="dev.tfvars"
	 ```
4. Aplica la infraestructura:
	 ```bash
	 terraform apply -var-file="dev.tfvars"
	 ```

Esto creará todos los recursos en Azure, desplegará los contenedores desde ACR y configurará autoscaling para el API de TODOs.

## Buenas Prácticas y Dev

- Cada microservicio tiene su propio README con detalles de endpoints y configuración.
- Usa ramas feature/ para desarrollo y PRs para integración.
- El frontend y los microservicios pueden desarrollarse y probarse localmente usando Docker Compose.
- El despliegue en Azure replica la arquitectura local, pero usando servicios administrados.

## Créditos

Proyecto base para entrenamiento DevOps y microservicios.
Autores original:
 
Nicolas Cuellar Molina

Samuel Alvarez Alban
