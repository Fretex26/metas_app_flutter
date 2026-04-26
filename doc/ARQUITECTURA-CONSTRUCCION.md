# Arquitectura de construcción — Metas App y Back Metas App

Este documento describe **cómo están construidos** los proyectos **metas_app** (cliente Flutter) y **back_metas_app** (backend NestJS): patrones de arquitectura, capas, convenciones de carpetas y flujo de datos. Para la visión de componentes, despliegue y stack tecnológico, véase [ARQUITECTURA-SISTEMA.md](./ARQUITECTURA-SISTEMA.md).

---

## 1. Enfoque general

Ambos proyectos siguen una **arquitectura en capas** inspirada en **Clean Architecture** y organización por **dominio/feature**:

- **Reglas de dependencia**: las capas internas (dominio) no conocen las externas (infraestructura, presentación). La lógica de negocio depende solo de abstracciones (repositorios, interfaces).
- **Organización por feature/módulo**: cada funcionalidad (auth, projects, sponsored_goals, etc.) se agrupa en su propia carpeta/módulo, con las mismas capas dentro.
- **Testabilidad y mantenibilidad**: los use cases dependen de interfaces de repositorio; las implementaciones concretas (HTTP, TypeORM) se inyectan o se registran en un solo lugar.

---

## 2. metas_app (Flutter) — Arquitectura del cliente

### 2.1 Estructura de carpetas

El código de la aplicación vive bajo `lib/` con esta estructura:

```
lib/
├── main.dart                 # Punto de entrada; registro de BlocProvider y rutas
├── core/                     # Configuración y elementos transversales
│   └── config/
│       └── api_config.dart   # URL base del API (API_BASE_URL)
├── themes/                   # Temas claro/oscuro
│   ├── light.mode.dart
│   └── dark.mode.dart
└── features/                 # Funcionalidades por dominio
    ├── auth/
    ├── admin/
    ├── projects/
    ├── sponsored_goals/
    ├── user/
    ├── sponsor/
    ├── home/
    └── ...
```

Cada **feature** replica la misma estructura de capas:

```
features/<nombre_feature>/
├── domain/                   # Capa de dominio (entidades, contratos)
│   ├── entities/             # Entidades de negocio (sin detalles de persistencia)
│   └── repositories/         # Interfaces abstractas de repositorios (*.repository.dart)
├── application/              # Casos de uso (orquestación)
│   └── use_cases/            # Use cases que usan los repositorios (*.use_case.dart)
├── infrastructure/           # Implementaciones concretas
│   ├── datasources/          # Llamadas HTTP (Dio) al backend (*_datasource.dart)
│   ├── dto/                  # DTOs de request/response (*.dto.dart)
│   ├── mappers/              # Mapeo DTO ↔ Entity (*.mapper.dart)
│   └── repositories_impl/    # Implementaciones de los repositorios (*.repository_impl.dart)
└── presentation/             # UI y estado
    ├── cubits/               # Estado con flutter_bloc (*.cubit.dart, *.states.dart)
    ├── pages/                # Pantallas (*.page.dart)
    └── components/           # Widgets reutilizables de la feature
```

### 2.2 Capas y responsabilidades

| Capa | Responsabilidad | Depende de |
|------|-----------------|------------|
| **domain** | Entidades puras y contratos (repositorios). Sin Flutter ni Dio. | Nada (núcleo) |
| **application** | Use cases: orquestan repositorios y aplican reglas de aplicación. | domain |
| **infrastructure** | Datasources (HTTP con Dio), DTOs, mappers, implementación de repositorios. | domain (y DTOs propios) |
| **presentation** | Cubits (estado), páginas y componentes. Llaman a use cases o repositorios inyectados. | application / domain |

### 2.3 Flujo típico en el cliente

1. **UI** (página/widget) usa un **Cubit** (flutter_bloc).
2. El **Cubit** llama a uno o más **use cases** (inyectados en `main.dart` vía repositorios).
3. El **use case** usa las interfaces de **repositorio** (domain).
4. La **implementación del repositorio** (infrastructure) usa un **datasource** que hace peticiones **Dio** a `ApiConfig.baseUrl`.
5. El **datasource** devuelve DTOs; el **repositorio** usa **mappers** para convertir a **entidades** de dominio y las devuelve al use case.
6. El use case devuelve el resultado al Cubit, que actualiza el estado y la UI se redibuja.

### 2.4 Convenciones y tecnologías clave (cliente)

- **Estado**: flutter_bloc con **Cubits** (no Blocs con eventos).
- **HTTP**: **Dio**; base URL en `lib/core/config/api_config.dart`.
- **Autenticación**: Firebase Auth + Google Sign-In; el token se envía como `Authorization: Bearer <id_token>` en las peticiones.
- **Nomenclatura**:  
  - Repositorios: `XxxRepository` (interface), `XxxRepositoryImpl` (implementación).  
  - Use cases: `verbo_objeto.use_case.dart` (ej. `get_sponsored_goal_by_id.use_case.dart`).  
  - Datasources: `*_datasource.dart`.  
  - Cubits: `nombre.cubit.dart` y `nombre.states.dart`.

---

## 3. back_metas_app (NestJS) — Arquitectura del backend

### 3.1 Estructura de carpetas

El código del backend está en `src/`:

```
src/
├── main.ts                   # Bootstrap: NestFactory, CORS, prefijo /api, ValidationPipe, Swagger
├── app.module.ts             # Módulo raíz; importa todos los módulos de negocio
├── app.controller.ts / app.service.ts
├── config/                   # Configuración (BD, Firebase Admin, etc.)
│   ├── database.config.ts
│   └── firebase-admin.module.ts
├── shared/                   # Elementos transversales
│   ├── filters/              # Filtros de excepciones (HttpExceptionFilter)
│   ├── interceptors/        # Ej. LoadUserInterceptor
│   └── ...
└── modules/                  # Módulos por dominio (cada uno = un feature)
    ├── auth/
    ├── users/
    ├── admin/
    ├── projects/
    ├── milestones/
    ├── sprints/
    ├── tasks/
    ├── sponsored-goals/
    ├── sponsors/
    ├── categories/
    ├── daily-entries/
    ├── reviews/
    ├── retrospectives/
    ├── gamification/
    ├── statistics/
    ├── audit/
    └── ...
```

Cada **módulo** sigue la misma estructura de capas:

```
modules/<nombre-modulo>/
├── <nombre>.module.ts        # Definición del módulo Nest (imports, controllers, providers)
├── domain/                   # Dominio
│   ├── entities/             # Entidades de negocio (*.entity.ts)
│   ├── repositories/         # Interfaces de repositorio (I*Repository)
│   └── value-objects/        # Objetos de valor (opcional)
├── application/              # Casos de uso y DTOs de aplicación
│   ├── use-cases/            # Use cases (*.use-case.ts)
│   └── dto/                  # DTOs de request/response (opcional, a veces en use-cases)
├── infrastructure/           # Implementaciones
│   ├── persistence/          # TypeORM: entidades ORM (*.orm-entity.ts), repositorios (*.repository.impl.ts)
│   └── mappers/              # Mapeo ORM/entity ↔ domain entity (*.mapper.ts)
└── presentation/             # Entrada HTTP
    └── *.controller.ts       # Controladores REST
```

### 3.2 Capas y responsabilidades (backend)

| Capa | Responsabilidad | Depende de |
|------|-----------------|------------|
| **domain** | Entidades, interfaces de repositorio, value objects. Sin Nest ni TypeORM. | Nada |
| **application** | Use cases y DTOs; orquestan repositorios y aplican reglas. | domain |
| **infrastructure** | Entidades ORM (TypeORM), implementaciones de repositorios, mappers. | domain |
| **presentation** | Controladores: validación (class-validator), llamada a use cases, respuestas HTTP. | application |

### 3.3 Inyección de dependencias (backend)

- Los **repositorios** se registran en el módulo con un **token** (ej. `'ISponsoredGoalRepository'`) y la clase de implementación (`SponsoredGoalRepositoryImpl`).
- Los **use cases** reciben los repositorios por constructor con `@Inject('TOKEN')`.
- Los **controladores** reciben los use cases por constructor; NestJS los inyecta automáticamente.

Ejemplo en un módulo:

```ts
providers: [
  { provide: 'ISponsoredGoalRepository', useClass: SponsoredGoalRepositoryImpl },
  CreateSponsoredGoalUseCase,
  GetSponsoredGoalByIdUseCase,
  // ...
],
```

### 3.4 Flujo típico en el backend

1. **Request** llega a un **Controller** (prefijo global `/api`).
2. **Guards/Interceptors** validan JWT (Firebase) y, si aplica, cargan el usuario en el contexto.
3. El **Controller** valida el body/query con DTOs (class-validator) y llama a un **use case**.
4. El **use case** usa las interfaces de **repositorio** inyectadas.
5. La **implementación del repositorio** usa **TypeORM** (entidades ORM) y **mappers** para devolver entidades de dominio.
6. El use case devuelve el resultado; el controller lo transforma a DTO de respuesta y responde HTTP.

### 3.5 Convenciones y tecnologías clave (backend)

- **API**: prefijo global `/api`; documentación Swagger en `/api/docs`.
- **Validación**: `ValidationPipe` global; DTOs con class-validator y class-transformer.
- **ORM**: TypeORM; entidades en `infrastructure/persistence/*.orm-entity.ts`; migraciones en `migrations/`.
- **Autenticación**: Firebase Admin SDK para verificar el JWT (Bearer token) y obtener el usuario.
- **Nomenclatura**:  
  - Repositorios: interfaz `IXxxRepository`, implementación `XxxRepositoryImpl`.  
  - Use cases: `accion-objeto.use-case.ts` (ej. `get-sponsored-goal-by-id.use-case.ts`).  
  - ORM: `*.orm-entity.ts`; controladores: `*.controller.ts`.

---

## 4. Correspondencia entre cliente y backend

Ambos proyectos reflejan el **mismo dominio** y la misma separación de responsabilidades:

| Concepto | metas_app (Flutter) | back_metas_app (NestJS) |
|----------|----------------------|--------------------------|
| Unidad de organización | `features/<nombre>/` | `modules/<nombre>/` |
| Contrato de datos | `domain/entities/` | `domain/entities/` |
| Contrato de persistencia | `domain/repositories/` | `domain/repositories/` (interfaces) |
| Orquestación | `application/use_cases/` | `application/use-cases/` |
| Acceso a datos | `infrastructure/datasources/` (Dio) | `infrastructure/persistence/` (TypeORM) |
| Entrada/salida externa | `presentation/cubits/` + pages | `presentation/*.controller.ts` |
| Configuración global | `core/config/api_config.dart` | `config/`, `main.ts` |

El cliente **no** implementa persistencia local propia para el dominio principal: usa el backend como única fuente de verdad vía API REST; Firebase solo se usa para autenticación.

---

## 5. Resumen

- **metas_app** y **back_metas_app** están construidos con una **arquitectura en capas** alineada con Clean Architecture y organización por **feature/módulo**.
- **Domain** define entidades y contratos (repositorios); **application** contiene los use cases; **infrastructure** implementa acceso a datos (Dio en el cliente, TypeORM en el backend); **presentation** expone la interfaz (Cubits/páginas en Flutter, controladores en NestJS).
- Las dependencias apuntan hacia dentro: dominio sin dependencias de framework; use cases y UI/API dependen de abstracciones del dominio.
- Las convenciones de nombres y la estructura de carpetas son consistentes entre ambos proyectos para facilitar el mantenimiento y la evolución del sistema.

Para detalles de despliegue, URLs y stack tecnológico completo, consultar [ARQUITECTURA-SISTEMA.md](./ARQUITECTURA-SISTEMA.md).
