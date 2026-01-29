# Daily entries: filtro por sprint (frontend)

Alineación con el backend: **cada daily entry pertenece a un sprint**. En la app se exige `sprintId` al obtener por fecha y se usa el sprint actual en la página de detalle del sprint.

---

## 1. Resumen de cambios

| Aspecto | Antes | Ahora |
|--------|--------|--------|
| **GET por fecha** | Sin `sprintId` | `sprintId` **obligatorio** en la llamada |
| **Sin entrada** | Backend podía devolver 200 con null | Backend devuelve **404**; en frontend se interpreta como "no hay entrada" (estado loaded con null) |
| **Página detalle sprint** | Cargaba daily por fecha solo | Carga daily por **fecha + sprintId** del sprint actual |

---

## 2. Capas afectadas

- **Datasource** (`daily_entry_datasource.dart`): `getDailyEntryByDate(date, sprintId)`; GET con query `sprintId`; 404 → retorno `null`.
- **Repository** (interface e impl): `getDailyEntryByDate(date, sprintId)`.
- **Use case** (`get_daily_entry_by_date.use_case.dart`): `call(date, sprintId)`.
- **Cubit** (`get_daily_entry_by_date.cubit.dart`): `loadDailyEntryByDate(date, sprintId)` y `refresh(date, sprintId)`.
- **UI** (`sprint_detail.page.dart`): Todas las llamadas al cubit pasan el `sprintId` del sprint de la página (creación del cubit, refresh en didChangeDependencies, refresh tras pull-to-refresh, refresh tras crear daily).

---

## 3. Referencia backend

Ver documento del backend: `DOC-DAILY-ENTRIES-SPRINT-FILTER.md` (repositorio back_metas_app).

Endpoint: `GET /api/daily-entries/date/:date?sprintId=:sprintId` (sprintId obligatorio). Respuesta 404 = no hay entrada para esa fecha en ese sprint.
