# Backend: cabecera Connection: close para auth/me

## Contexto del problema

La app Flutter en **dispositivo físico Android** llama a `GET /api/auth/me` tras el login. El backend (NestJS en Railway) **sí recibe la petición** y la procesa correctamente (en los logs de Railway se ve que `FirebaseAuthGuard` valida el token y establece `request.user`).

Sin embargo, en el cliente:

- La petición **sale** (se ve en logs del app que la request se envía).
- El **Future de la petición HTTP nunca completa**: no llega respuesta ni error ni timeout (probado con Dio y con el paquete `http`, y con timeouts de 10–15 s).
- En el navegador del mismo dispositivo, Swagger y la API sí responden bien.

Conclusión: la respuesta del servidor **no está llegando** al cliente en ese contexto (o la conexión no se cierra y el cliente queda esperando). Por eso se propone que el backend **cierre explícitamente la conexión** tras enviar la respuesta, usando la cabecera `Connection: close`.

## Cambios solicitados en el backend

### 1. Enviar `Connection: close` en la respuesta

Objetivo: que el servidor cierre la conexión TCP después de enviar la respuesta, para que el cliente no quede esperando más datos o reutilización de conexión.

**Opción A – Global (recomendada)**  
En `main.ts`, antes de `await app.listen(...)`:

```ts
app.use((req: Request, res: Response, next: NextFunction) => {
  res.setHeader('Connection', 'close');
  next();
});
```

(Asegurar tener los tipos de Express: `Request`, `Response`, `NextFunction`.)

**Opción B – Solo para rutas bajo `/api/auth`**  
Si preferís no afectar al resto de la API, se puede aplicar solo a las rutas de auth (p. ej. en un middleware o interceptor que se aplique solo a `/api/auth/*`), estableciendo en la respuesta:

```ts
res.setHeader('Connection', 'close');
```

**Opción C – Interceptor de NestJS**  
En un interceptor que se ejecute para las respuestas que queráis (p. ej. todas o solo auth):

```ts
// Dentro del interceptor, antes de next.handle() o al transformar la respuesta
context.getResponse().setHeader('Connection', 'close');
return next.handle();
```

Cualquiera de estas opciones es válida; la A es la más simple si no hay restricción en aplicarlo a toda la API.

### 2. Verificación

Tras desplegar:

1. Comprobar en los logs de Railway que las peticiones a `/api/auth/me` siguen llegando y respondiendo 200 (o 401 cuando corresponda).
2. En la app Flutter en dispositivo físico, volver a hacer login y comprobar si la llamada a auth/me completa y la app entra correctamente.

## Resumen técnico para el back

| Aspecto | Detalle |
|--------|--------|
| Endpoint afectado | `GET /api/auth/me` (y en principio cualquier ruta si se usa la opción global) |
| Cambio pedido | Añadir cabecera de respuesta `Connection: close` |
| Motivo | El cliente Android no recibe/cierra la respuesta; forzar cierre de conexión en el servidor puede corregirlo |
| Cliente | Flutter (Dio y paquete `http` probados); en el mismo dispositivo, el navegador sí recibe respuesta |

Si necesitáis más detalle de logs del cliente o del backend, se puede ampliar este documento.
