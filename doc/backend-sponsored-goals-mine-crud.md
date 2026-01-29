# Backend: endpoints para “Mis objetivos” del sponsor

El frontend implementa **ver, editar y eliminar** los objetivos patrocinados del sponsor. Para ello se asume que el backend expone los siguientes endpoints. Si aún no existen, hay que implementarlos.

## Endpoints requeridos

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/api/sponsored-goals/mine` | Lista los sponsored goals del sponsor autenticado. Respuesta: `List<SponsoredGoalResponseDto>`. |
| `GET` | `/api/sponsored-goals/:id` | Obtiene un sponsored goal por ID. Solo el sponsor dueño. 403 si no es dueño, 404 si no existe. |
| `PATCH` | `/api/sponsored-goals/:id` | Actualiza un sponsored goal (solo sponsor dueño). Body: objeto parcial (campos opcionales). Ver abajo. |
| `DELETE` | `/api/sponsored-goals/:id` | Elimina un sponsored goal (solo sponsor dueño). 204 o 200 sin body. |

Todos bajo **`/api`**, con **`Authorization: Bearer <Firebase ID token>`**.

## PATCH body (`UpdateSponsoredGoalDto`)

Solo se envían los campos que se modifican. Ejemplo:

```json
{
  "name": "Nuevo nombre",
  "description": "Nueva descripción",
  "startDate": "2025-02-01",
  "endDate": "2025-03-31",
  "maxUsers": 50,
  "categoryIds": ["uuid1", "uuid2"],
  "rewardId": "uuid-opcional"
}
```

- `projectId` **no** se puede cambiar.
- Formatos de fecha: `YYYY-MM-DD`.

## Respuestas

- **GET /mine**, **GET /:id**, **PATCH /:id**: mismo contrato que `SponsoredGoalResponseDto` (p. ej. como en `POST /api/sponsored-goals` o `GET /api/sponsored-goals/available`).
- **DELETE /:id**: 204 No Content (o 200 sin body).

## Errores

- **401**: No autorizado.
- **403**: No es sponsor o no es dueño del objetivo.
- **404**: Sponsored goal no encontrado.
- **400**: Validación (p. ej. fechas incoherentes, `maxUsers` &lt; 1). Body con `message` o `error` recomendado.
