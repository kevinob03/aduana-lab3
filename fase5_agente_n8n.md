# Fase 5 — Agente de IA en n8n

## Resultado preparado

Se preparó el archivo `Agente_Aduana_n8n.json` para importar en n8n. El flujo tiene esta estructura:

```text
Chat Trigger  →  AI Agent  →  respuesta en el chat
                    ├── OpenAI Chat Model
                    ├── Simple Memory
                    └── MySQL - Solo lectura (herramienta)
```

El **Chat Trigger** recibe la pregunta escrita por el usuario. El **AI Agent** entiende la pregunta, decide si necesita consultar la base y redacta la respuesta. El modelo de chat es el LLM que usa el agente. La memoria permite entender preguntas seguidas dentro del mismo chat. Por último, MySQL es la herramienta que obtiene datos reales de la base.

La documentación de n8n explica que un AI Agent se puede extender con subnodos como modelo de chat, memoria y herramientas. También indica que MySQL permite ejecutar consultas SQL y puede utilizarse como herramienta de un agente: [conceptos de n8n](https://docs.n8n.io/get-started/key-concepts/) y [nodo MySQL](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.mysql/).

## Cómo importarlo y configurarlo

1. Primero ejecuta `Aduana_Lab3.sql` en MySQL Workbench para crear y llenar la base `aduana_lab3`.
2. Como administrador de MySQL, revisa `usuario_mysql_solo_lectura.sql`, cambia la contraseña de ejemplo y ejecútalo. Este usuario solo tendrá permiso `SELECT`.
3. En n8n, crea un workflow y elige el menú de opciones. Selecciona **Import from File** e importa `Agente_Aduana_n8n.json`.
4. Abre el nodo **OpenAI Chat Model**. Crea o selecciona una credencial de OpenAI y comprueba que el modelo elegido esté disponible en tu cuenta. Si no lo está, selecciona otro modelo de chat compatible.
5. Abre el nodo **MySQL - Solo lectura**. Crea una credencial MySQL con estos datos:
   - Host: `localhost` si MySQL y n8n están en la misma computadora; de lo contrario, usa el host accesible desde n8n.
   - Base de datos: `aduana_lab3`.
   - Usuario: `agente_aduana_lectura`.
   - Contraseña: la que configuraste en el archivo de usuario.
6. Comprueba que las conexiones desde OpenAI Chat Model, Simple Memory y MySQL lleguen al AI Agent. En algunas versiones de n8n, si el importado muestra un campo diferente, vuelve a conectar visualmente el nodo a los puertos **Chat Model**, **Memory** y **Tool** del agente.
7. Guarda el flujo, abre el chat de prueba del Chat Trigger y realiza las preguntas de la tabla de pruebas. Cuando funcione, activa el workflow.
8. Exporta el flujo desde el menú **··· > Download**. Antes de entregarlo, confirma que el archivo no incluye contraseñas o claves API.

## Seguridad aplicada

La seguridad no depende solo del prompt. Se aplican dos capas:

1. El mensaje de sistema le ordena al agente generar una única consulta que comience con `SELECT` y le prohíbe cambiar o borrar datos.
2. El usuario `agente_aduana_lectura` recibe solamente `GRANT SELECT ON aduana_lab3.*`. Aunque el modelo cometiera un error, MySQL no le permitirá ejecutar `INSERT`, `UPDATE`, `DELETE`, `DROP` ni cambios de permisos.

La segunda capa es la más importante. El prompt ayuda al comportamiento del modelo, pero los permisos de MySQL son los que protegen realmente la información.

## Mensaje de sistema utilizado

El mensaje ya está dentro del nodo AI Agent del archivo JSON. Incluye las 13 tablas, sus columnas, relaciones importantes y estas reglas principales:

- Usar MySQL para responder preguntas que dependan del inventario.
- No inventar resultados.
- Ejecutar solamente un `SELECT` por vez.
- No usar comandos de cambio de datos ni de estructura.
- Evitar `SELECT *` y limitar resultados grandes a 100 filas.

Esto es importante porque el agente necesita conocer los nombres reales de las tablas; si se los inventa, la consulta falla.

## Pruebas requeridas y evidencia

Haz una captura donde se vea la pregunta y la respuesta de cada una. Marca la última columna cuando la prueba funcione.

| # | Pregunta para el chat | Qué se espera comprobar | Evidencia |
|---|---|---|---|
| 1 | ¿Cuántas declaraciones de importación se registraron en octubre? | Debe devolver 11 con los datos actuales. | ⬜ |
| 2 | ¿Qué mercancías siguen retenidas y en qué bodega están? | Debe listar producto, cantidad y bodega. | ⬜ |
| 3 | ¿Qué mercancías de China siguen retenidas en la bodega 2? | Debe encontrar computadoras y adaptadores. | ⬜ |
| 4 | ¿Cuál es el país de origen con más contenedores recibidos? | Debe responder China. | ⬜ |
| 5 | ¿Qué importador ha declarado el mayor valor total en mercancías? | Debe identificar a Automotriz del Istmo S.A. | ⬜ |
| 6 | ¿Qué inspecciones tuvieron resultado con observaciones y quién las realizó? | Debe mostrar declaración, funcionario y observación. | ⬜ |
| 7 | ¿Cuánto stock queda del producto Telefono inteligente de 128 GB en todas las bodegas? | Debe mostrar 200 en Bodega 1 y 150 en Bodega 9. | ⬜ |
| 8 | ¿Cuánto inventario ingresó a cada bodega durante octubre? | Debe agrupar las entradas de octubre por bodega. | ⬜ |

## Problemas comunes

- **El agente responde sin datos:** revisa que el nodo MySQL esté conectado al puerto Tool del AI Agent y que la credencial apunte a `aduana_lab3`.
- **Access denied:** confirma host, usuario, contraseña y que el permiso `SELECT` se creó para el host correcto.
- **La conexión falla al usar Docker:** `localhost` dentro de un contenedor es el propio contenedor, no la computadora anfitriona. Hay que usar el nombre del servicio MySQL o un host accesible en la red.
- **El flujo importado muestra nodos desactualizados:** n8n cambia con el tiempo. Conserva la estructura, crea de nuevo el nodo indicado y vuelve a conectar sus puertos si hace falta.

## Uso de IA para el informe

Durante esta práctica se utilizó ChatGPT/Codex para explicar conceptos de base de datos, revisar las relaciones del DER, proponer datos de prueba y redactar una guía de configuración de n8n. Un prompt de ejemplo fue: “Explícame cómo conectar un agente de n8n a MySQL de solo lectura para consultar un inventario aduanero”.

El aprendizaje principal fue que la IA ayuda a entender y revisar, pero no reemplaza las pruebas. Fue necesario revisar nombres de tablas, relaciones, permisos y resultados reales antes de considerar terminado el agente.

## Fuentes consultadas

1. n8n. [Documentación general de n8n](https://docs.n8n.io/).
2. n8n. [Conceptos y glosario](https://docs.n8n.io/get-started/key-concepts/).
3. n8n. [Nodo MySQL](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.mysql/).
4. n8n. [Conceptos de herramientas de IA](https://docs.n8n.io/advanced-ai/examples-and-concepts/what-is-a-tool/).
