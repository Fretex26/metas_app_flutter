# Portal Sponsor y Administrador (Frontend)

Documentación de la implementación en Flutter del **portal sponsor**, **portal administrador**, flujos de registro y redirección según rol y estado del sponsor. Alineado con las instrucciones del backend (`INSTRUCCIONES_PORTAL_SPONSOR_Y_ADMIN`).

---

## 1. Resumen

- **Usuario normal** (`role: user`): Portal estándar (proyectos, milestones, tasks, checklist, sprints, dailies, reviews, retrospectives, rewards).
- **Sponsor** (`role: sponsor`):
  - **PENDING**: Pantalla “En espera de aprobación”; solo cerrar sesión.
  - **APPROVED**: Portal sponsor (proyectos, milestones, tasks, checklist). **Sin** sprints, dailies, reviews ni retrospectives.
  - **REJECTED** / **DISABLED**: Pantalla “Acceso denegado”; solo cerrar sesión.
- **Admin** (`role: admin`): Portal admin (gestión de sponsors: listar, aprobar, rechazar, deshabilitar, habilitar).

---

## 2. Auth y sesión

- Tras login o `checkAuth`, se llama **`GET /api/auth/me`** para obtener `user` + `sponsor` (si aplica).
- La redirección se hace con `AuthSuccess(session: AuthMeSession)`:
  - `session.user.role` → `user` | `sponsor` | `admin`
  - `session.sponsor?.status` → `pending` | `approved` | `rejected` | `disabled`

Archivos relevantes:

- `lib/features/auth/domain/entities/auth_me_session.dart`
- `lib/features/auth/infrastructure/datasources/auth_me_datasource.dart`
- `lib/features/auth/application/use_cases/get_auth_me.use_case.dart`
- `AuthCubit`: usa `GetAuthMeUseCase` tras login/checkAuth y emite `AuthSuccess(session)`.

---

## 3. Registro sponsor

- En registro (email/password o Google) el usuario puede elegir **“Patrocinar proyectos (rol sponsor)”**.
- Si elige sponsor, se muestran campos extra: **Nombre del negocio**, **Descripción**, **Email de contacto**.
- Flujo:
  1. Firebase Auth (crear usuario o completar Google).
  2. `POST /api/users` con `role: sponsor`.
  3. `POST /api/sponsors` con `businessName`, `description`, `contactEmail`.
- El sponsor queda **PENDING** hasta que un admin lo apruebe.

Archivos:

- `lib/features/auth/presentation/pages/register.page.dart` (formulario + campos sponsor).
- `lib/features/sponsor/infrastructure/dto/create_sponsor.dto.dart`
- `lib/features/sponsor/infrastructure/datasources/sponsor_datasource.dart`
- `CreateSponsorUseCase`; `AuthCubit.signUp` / `completeGoogleRegistration` con `sponsorData`.

---

## 4. Pantallas específicas

- **En espera de aprobación** (`SponsorPendingPage`): sponsors **PENDING**. Mensaje y botón “Cerrar sesión”.
- **Acceso denegado** (`AccessDeniedPage`): sponsors **REJECTED** o **DISABLED**. Mensaje y “Cerrar sesión”.

Ubicación: `lib/features/auth/presentation/pages/`.

---

## 5. Portal sponsor (APPROVED)

- Reutiliza **proyectos**, **milestones**, **tasks** y **checklist** (crear, editar, eliminar).
- **No** se muestran ni usan:
  - Sprints (crear, listar, abrir detalle).
  - Dailies, reviews, retrospectives.
  - Diálogo de sprints pendientes.
- Implementación:
  - `MainNavigationPage(isSponsor: true)` → `ProjectsListPage(isSponsor: true)` → `ProjectDetailPage` → `MilestoneDetailPage(isSponsor: true)`.
  - En `MilestoneDetailPage`, si `isSponsor == true`, se oculta toda la sección “Sprints” (crear, listar, navegar a `SprintDetailPage`).
  - En `MainNavigationPage`, si `isSponsor == true`, no se cargan ni se muestran los sprints pendientes.

La creación de **Sponsored Goals** (publicar proyecto como objetivo patrocinado) y la **inscripción de usuarios** se implementarán más adelante.

---

## 6. Portal administrador

- Solo accesible si `session.user.role == admin`.
- **AdminSponsorsPage**:
  - Lista “Pendientes de aprobación” (equivalente a `GET /api/admin/sponsors/pending`).
  - Lista “Todos los sponsors” con filtro por estado (`pending` | `approved` | `rejected` | `disabled`).
  - Por sponsor: **Aprobar** / **Rechazar** (pendientes), **Deshabilitar** (aprobados), **Habilitar** (deshabilitados).

Archivos:

- `lib/features/admin/application/use_cases/admin_sponsors.use_cases.dart`
- `lib/features/admin/infrastructure/datasources/admin_sponsors_datasource.dart`
- `lib/features/admin/presentation/pages/admin_sponsors.page.dart`
- `lib/features/admin/presentation/cubits/admin_sponsors.cubit.dart`

---

## 7. Redirección post-login

En `main.dart`, dentro del `BlocConsumer<AuthCubit, AuthStates>`:

- `Unauthenticated` → `AuthPage`.
- `AuthSuccess`:
  - `session.isAdmin` → `AdminSponsorsPage`.
  - `session.isSponsor`:
    - `isSponsorPending` → `SponsorPendingPage`.
    - `isSponsorRejectedOrDisabled` → `AccessDeniedPage`.
    - En caso contrario (APPROVED) → `MainNavigationPage(isSponsor: true)`.
  - Resto (user) → `MainNavigationPage(isSponsor: false)`.
- `GoogleAuthPendingRegistration` → `RegisterPage` (completar registro).

---

## 8. Componentes reutilizados

- `MyButton`, `MyTextField`, `MyTextFieldMultiline`, `MyRoleDropdown`, `MyDropdown`.
- `ProjectCard`, `MilestoneCard`, `TaskCard`, `StatusBadge`, `DeleteConfirmationDialog`, etc.
- Tema y estilos existentes (p. ej. `light.mode`, `dark.mode`).

---

## 9. Endpoints utilizados

| Uso            | Método | Ruta |
|----------------|--------|------|
| Sesión         | GET    | `/api/auth/me` |
| Registro user  | POST   | `/api/users` |
| Registro sponsor | POST | `/api/sponsors` |
| Admin pendientes | GET  | `/api/admin/sponsors/pending` |
| Admin todos    | GET    | `/api/admin/sponsors` (`?status=`) |
| Admin detalle  | GET    | `/api/admin/sponsors/:id` |
| Admin aprobar  | POST   | `/api/admin/sponsors/:id/approve` |
| Admin rechazar | POST   | `/api/admin/sponsors/:id/reject` |
| Admin deshabilitar | POST | `/api/admin/sponsors/:id/disable` |
| Admin habilitar | POST  | `/api/admin/sponsors/:id/enable` |

Proyectos, milestones, tasks, checklist, etc. usan los mismos endpoints que el usuario normal (los sponsors aprobados comparten esos recursos).

---

## 10. Referencia de archivos nuevos/modificados

- **Auth / sesión**: `auth_me_session`, `auth_me_response.dto`, `auth_me_datasource`, `get_auth_me.use_case`, `auth.states`, `auth.cubit`, `register.page`.
- **Sponsor**: `create_sponsor.dto`, `sponsor_datasource`, `create_sponsor.use_case`; `sponsor_pending.page`, `access_denied.page`.
- **Admin**: `admin_sponsor`, `admin_sponsor_response.dto`, `admin_sponsors_datasource`, `admin_sponsors.use_cases`, `admin_sponsors.cubit`, `admin_sponsors.page`.
- **Navegación / proyectos**: `main.dart`, `main_navigation.page`, `projects_list.page`, `project_detail.page`, `milestone_detail.page`.
