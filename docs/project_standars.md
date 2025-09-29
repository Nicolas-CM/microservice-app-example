# Estándares del Proyecto

## Metodología: Kanban

### Tablero Kanban

- **Backlog**: Tareas pendientes por iniciar
- **Ready**: Tareas listas para ser tomadas
- **In Progress**: Tareas en desarrollo
- **Review**: Tareas en revisión
- **Done**: Tareas completadas

![Kanban Board](images/kanban.png)

## Estrategia de Branching

### Ramas de Desarrollo

Utilizamos Feature Branching para desarrollo, lo que permite trabajo paralelo y control de calidad.

![Feature Branching Strategy](images/feature_branching.png)

#### Ramas Principales

| Rama | Propósito | Origen | Merge a |
|------|-----------|--------|----------|
| `main` | Código en producción | - | - |
| `develop` | Desarrollo activo | `main` | `main` |

#### Ramas de Funcionalidad

| Tipo | Formato | Propósito | Origen | Merge a |
|------|---------|-----------|--------|----------|
| Feature | `feature/nombre` | Nuevas funcionalidades | `develop` | `develop` |
| Bugfix | `bugfix/description` | Corrección de errores | `develop` | `develop` |
| Hotfix | `hotfix/description` | Correcciones urgentes | `main` | `main` y `develop` |

### Ramas de Infraestructura

Utilizamos Main-Only Strategy para infraestructura, priorizando la estabilidad y simplicidad.

![Main-Only Strategy](images/main-only_strategy.png)

#### Ramas Principales

| Rama | Propósito | Origen | Merge a |
|------|-----------|--------|----------|
| `main` | Infraestructura en producción | - | - |
| `infra-develop` | Cambios de infraestructura | `main` | `main` |

## Estándar de Commits

| Tipo | Uso |
|------|-----|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de errores |
| `docs` | Documentación |
| `infra` | Cambios en infraestructura |
| `test` | Pruebas |

### Example

docs: adding images

## [Volver al README](../README.md)