# Usuario administrador

Este documento describe las capacidades del **usuario administrador** en la aplicación Metas.

---

## Acceso

- El administrador es un usuario con **rol `admin`** en el backend.
- Tras iniciar sesión (Firebase), la aplicación redirige automáticamente al **portal de administración** (página *Gestión de sponsors*).
- El administrador **no** accede al resto de la app (proyectos, recompensas, objetivos); su interfaz se limita a la gestión de sponsors.

---

## Funcionalidades

### 1. Gestión de sponsors

El administrador puede:

| Acción | Descripción |
|--------|-------------|
| **Ver pendientes** | Lista de sponsors con estado **Pendientes de aprobación** (solicitudes nuevas). |
| **Ver todos** | Lista de todos los sponsors, con filtro opcional por estado. |
| **Filtrar por estado** | En "Todos los sponsors" puede filtrar por: Todos, Pendientes, Aprobados, Rechazados, Deshabilitados. |
| **Aprobar** | Cambia un sponsor de **PENDING** → **APPROVED**. El sponsor podrá usar el portal de sponsor. |
| **Rechazar** | Cambia un sponsor de **PENDING** → **REJECTED**. Puede indicar un motivo opcional. El sponsor no podrá acceder. |
| **Deshabilitar** | Cambia un sponsor **APPROVED** → **DISABLED**. El sponsor pierde acceso de inmediato. |
| **Habilitar** | Cambia un sponsor **DISABLED** → **APPROVED**. El sponsor recupera el acceso. |

### 2. Información mostrada por sponsor

En cada tarjeta de sponsor se muestra:

- Nombre del negocio (*businessName*).
- Estado (chip de color: pendiente, aprobado, rechazado, deshabilitado).
- Nombre y email del usuario asociado.
- Descripción (si existe).

### 3. Otras acciones en la interfaz

- **Actualizar lista**: arrastrar hacia abajo (pull-to-refresh) para recargar pendientes y lista filtrada.
- **Cerrar sesión**: botón de logout en la barra superior.

---

## Estados de un sponsor

| Estado | Significado |
|--------|-------------|
| `pending` | Solicitud registrada; esperando aprobación del admin. |
| `approved` | Aprobado; puede usar el portal sponsor. |
| `rejected` | Rechazado por el admin; no puede acceder. |
| `disabled` | Deshabilitado por el admin; no puede acceder hasta ser habilitado de nuevo. |

---

## Restricciones y errores

- Todas las operaciones de administración requieren **autenticación** (token Firebase) y **rol admin** en el backend.
- Si el token expira o no tiene permisos (401/403), la app muestra mensajes como *Acceso denegado* o *Error de autenticación* y permite cerrar sesión.
- Las acciones solo están disponibles cuando el estado del sponsor lo permite (por ejemplo, solo se puede aprobar/rechazar si está `pending`, y deshabilitar solo si está `approved`).

---

## Resumen

El **usuario administrador** puede:

1. Ver sponsors **pendientes de aprobación** y **todos** los sponsors (con filtro).
2. **Aprobar** o **Rechazar** sponsors en estado pendiente (con motivo opcional al rechazar).
3. **Deshabilitar** sponsors aprobados y **Habilitar** sponsors deshabilitados.
4. **Cerrar sesión** desde el portal de administración.

No tiene en la app otras pantallas (proyectos, recompensas, objetivos); su función se centra en la moderación del acceso de sponsors.
