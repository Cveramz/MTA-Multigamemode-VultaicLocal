# Vultaic MGM — Self-Hosted

Adaptación del gamemode Vultaic MGM para ejecutar un servidor propio de MTA:SA
1.6 sin los servicios privados de la instalación original.

## Cambios incluidos

- MariaDB 10.11 y Adminer mediante Docker Compose.
- Esquema inicial para cuentas, estadísticas, clanes, logros y top times.
- Configuración central de base de datos mediante `v_config`.
- Login con cuentas nativas de MTA; el primer acceso registra la cuenta.
- ACL mínima para que `v_login` pueda crear cuentas.
- Transferencia de elementos de mapas directamente por MTA, sin el antiguo
  servidor HTTP `http://host/storage`.
- Compatibilidad con MTA 1.6 para credenciales Base64 del login.
- Correcciones de carga de recursos y sincronización de datos de arena.
- Arenas DM, HDM, OS, FDD, Race, Shooter, Hunter y entrenamiento.

## Requisitos

- Una instalación limpia de MTA:SA Server 1.6.
- Docker Desktop usando contenedores Linux.
- PowerShell 5.1 o posterior.

## Instalación

Clona este repositorio dentro de la carpeta del servidor MTA o indica la ruta
del servidor con `-MtaServerRoot`.

```powershell
Copy-Item .env.example .env
docker compose up -d
.\setup.ps1 -DatabasePassword "la_misma_clave_de_env" -AdminAccount "tu_usuario"
```

Si el repositorio no está dentro de la carpeta del servidor:

```powershell
.\setup.ps1 -MtaServerRoot "C:\ruta\al\server" -DatabasePassword "la_misma_clave_de_env"
```

Inicia después `MTA Server.exe` y conecta a `mtasa://127.0.0.1:22003`.
Adminer estará en `http://127.0.0.1:8080` y solamente escuchará en localhost.

El instalador conserva el `mapmanager` original en
`backups/vultaic-selfhosted/native-mapmanager` antes de sustituirlo.

## Agregar mapas

Extrae cada mapa como una carpeta bajo:

```text
mods/deathmatch/resources/[maps]/nombre_del_recurso/
```

El `meta.xml` debe estar directamente en esa carpeta. El atributo `name` del
nodo `<info>` debe usar el prefijo de la arena, por ejemplo `[DM]`, `[HDM]`,
`[OS]` o `[Race]`. Luego ejecuta en la consola del servidor:

```text
refresh
refreshmaps all
```

Los mapas de terceros no se incluyen en este repositorio.

## Desarrollo y producción

La creación automática de cuentas es práctica para desarrollo. Antes de abrir
un servidor público conviene implementar un registro separado, limitar intentos
de login, usar contraseñas fuertes, configurar `owner_email_address` y revisar
los puertos/firewall. No publiques el archivo `.env`, bases de datos ni logs.

`docker compose down` detiene los contenedores pero conserva el volumen de la
base de datos. Para ver el estado usa `docker compose ps`.

