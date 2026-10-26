# Investigación inicial — Laboratorio #3: Sistema de inventario para una aduana

**Asignatura:** Bases de Datos  
**Estudiante(s):** ____________________  
**Gestor que se propone usar:** MySQL  
**Fecha:** ____________________

## Introducción

El caso plantea una aduana que recibe mercancías de varios países. Actualmente la información se guarda en hojas de cálculo separadas y esto puede causar errores, atrasos o pérdida de control sobre los productos. La idea del laboratorio es organizar esos datos en una base de datos y luego permitir consultas por medio de SQL y de un agente de IA en n8n.

Antes de crear tablas, es importante entender los conceptos básicos. Así se evita diseñar una base de datos que guarde información repetida o que relacione datos que no corresponden.

## A. Bases de datos y SQL

### 1. Base de datos y SGBD

Una **base de datos** es un conjunto organizado de información. Por ejemplo, en este caso podría guardar los importadores, productos, declaraciones, bodegas e inspecciones. No es solamente una lista: los datos se ordenan de forma que se puedan buscar, relacionar y actualizar.

Un **Sistema Gestor de Bases de Datos (SGBD)** es el programa que permite crear y administrar esa base de datos. MySQL, PostgreSQL y SQLite son ejemplos. El SGBD recibe instrucciones en SQL y se encarga de guardar los datos, aplicar reglas y devolver resultados.

### 2. Base de datos relacional y no relacional

En una base de datos **relacional**, la información se guarda en tablas relacionadas entre sí. Cada tabla representa un tema; por ejemplo, una tabla `pais` y otra tabla `declaracion`. La relación entre ambas se hace normalmente por identificadores. Es una buena opción para la aduana porque hay datos estructurados y relaciones claras.

Una base de datos **no relacional** o NoSQL no siempre usa tablas fijas. Puede guardar documentos parecidos a JSON, grafos o pares clave-valor. Es útil cuando los datos cambian mucho de forma o son muy grandes y variados. Para este laboratorio, una relacional es más adecuada porque se necesitan llaves, restricciones, consultas con `JOIN` y datos consistentes.

### 3. Tabla, registro, campo y tipos de datos

- Una **tabla** agrupa datos del mismo tipo, por ejemplo, `producto`.
- Un **registro** o fila representa un caso concreto, por ejemplo, el producto “computadora portátil”.
- Un **campo** o columna representa una característica, como `descripcion`, `valor_unitario` o `peso`.

Algunos tipos de datos comunes son `INT` para números enteros, `DECIMAL` para montos de dinero, `VARCHAR` para textos cortos, `DATE` para fechas, `BOOLEAN` para verdadero/falso y `TEXT` para observaciones más largas. Escoger bien el tipo ayuda a que los datos tengan sentido: un precio no debería guardarse como texto.

### 4. Llave primaria, llave foránea y llave compuesta

La **llave primaria** o PK identifica de forma única cada fila. Por ejemplo, `id_producto` permite distinguir un producto de todos los demás. No debe repetirse ni quedar vacía.

La **llave foránea** o FK es una columna que apunta a la PK de otra tabla. Por ejemplo, si una declaración contiene `id_pais_origen`, ese valor debe existir antes en la tabla `pais`. Con esto se conectan las tablas y se evita escribir el nombre del país una y otra vez.

Una **llave compuesta** usa dos o más columnas juntas para identificar una fila. Por ejemplo, en una tabla que une productos con bodegas, la combinación `(id_bodega, id_producto)` puede identificar el stock de un producto en una bodega. También se puede usar un identificador propio y dejar esa combinación como `UNIQUE`; se decidirá esto en el diseño posterior.

### 5. Relaciones entre entidades

Una relación **uno a uno (1:1)** significa que un registro se relaciona con uno solo del otro lado. Un ejemplo posible sería una declaración y su comprobante principal, si el sistema decide guardar dicho comprobante en otra tabla.

Una relación **uno a muchos (1:N)** significa que un registro de la primera tabla puede relacionarse con varios de la segunda. Por ejemplo, un país puede ser origen de muchas declaraciones, pero cada declaración tiene un país de origen.

Una relación **muchos a muchos (N:M)** necesita una tabla intermedia. Por ejemplo, una declaración puede incluir varios productos y un producto puede aparecer en varias declaraciones. La tabla `detalle_declaracion` guardaría las FK de declaración y producto, además de datos propios como cantidad y valor declarado.

### 6. Integridad referencial y restricciones

La **integridad referencial** es la regla que hace que una FK apunte a un registro existente. Por ejemplo, no debería poder insertarse una inspección para una declaración que no existe. PostgreSQL explica que una FK debe referenciar una PK o una columna con restricción `UNIQUE` [1].

Las restricciones ayudan a cuidar los datos:

- `NOT NULL`: el dato es obligatorio, como el número de una declaración.
- `UNIQUE`: no permite valores repetidos, como el código ISO de un país.
- `CHECK`: limita los valores aceptados, por ejemplo, que el régimen sea importación, exportación, tránsito o depósito.
- `DEFAULT`: asigna un valor inicial si no se escribe uno, por ejemplo, un estado inicial de “Retenida”.

### 7. DDL, DML y sentencias SQL

El **DDL** (Data Definition Language) sirve para definir la estructura. La sentencia `CREATE TABLE` crea una tabla y especifica sus columnas, tipos y reglas.

El **DML** (Data Manipulation Language) trabaja con los datos de las tablas:

- `INSERT` agrega filas.
- `SELECT` consulta datos.
- `UPDATE` modifica filas existentes.
- `DELETE` elimina filas.
- `JOIN` combina información de varias tablas relacionadas.

Por ejemplo, una consulta con `JOIN` puede mostrar el número de declaración, el nombre del importador y el país de origen en un solo resultado.

### 8. Normalización

La normalización es una forma de organizar las tablas para reducir repeticiones y errores.

- **Primera forma normal (1FN):** cada campo contiene un valor individual, no listas. En vez de guardar “teléfono1, teléfono2” en una sola celda, se organiza de una forma más clara.
- **Segunda forma normal (2FN):** además de estar en 1FN, los campos que no forman parte de una llave deben depender de la llave completa. Esto es importante sobre todo si hay llave compuesta.
- **Tercera forma normal (3FN):** además de cumplir 2FN, los campos no deben depender de otros campos no clave. Por ejemplo, el nombre del país se guarda en `pais`, no repetido dentro de cada declaración.

En este caso, normalizar evita repetir la información de importadores, países y productos en cada movimiento.

### 9. Diagrama Entidad-Relación (DER)

Un **DER** es un plano antes de construir la base de datos. Muestra las entidades, sus atributos y cómo se relacionan. Ayuda a revisar si faltan datos o si una relación está mal planteada antes de escribir SQL.

La notación **Chen** representa entidades como rectángulos, relaciones como rombos y atributos como óvalos. La notación de **pata de gallo** suele mostrar las entidades como cuadros con sus campos y usa líneas para indicar cardinalidad; la “pata” representa “muchos”. Para este laboratorio se puede dibujar a mano usando cualquiera de las dos, siempre señalando PK, FK y cardinalidades.

## B. Comparación de gestores de bases de datos

| Gestor | Ventajas para el laboratorio | Aspecto a considerar |
|---|---|---|
| SQLite | Es sencillo, no necesita servidor y guarda todo en un archivo. | La conexión con n8n no es tan directa. Además, sus llaves foráneas deben activarse por conexión con `PRAGMA foreign_keys = ON` [2]. |
| MySQL | Es popular, tiene muchos tutoriales y n8n posee un nodo para usar MySQL. | Se debe instalar/configurar un servidor, por ejemplo con XAMPP o Docker. |
| PostgreSQL | Es robusto, completo y también tiene integración con n8n. | Al inicio puede sentirse un poco más técnico de configurar. |

Para este laboratorio se propone usar **MySQL**, porque es común en cursos introductorios, se puede instalar con XAMPP y n8n tiene un nodo para ejecutar consultas SQL [3]. Esto facilita que la misma base usada para el script pueda conectarse después al agente. La decisión final se confirmará antes de la Fase 3.

## C. n8n y agentes de IA

**n8n** es una herramienta para automatizar flujos de trabajo. Un flujo o *workflow* conecta pasos visuales para que una acción active otra. Por ejemplo, un mensaje de usuario puede activar un agente, este consulta la base de datos y después devuelve una respuesta.

Un **nodo** es cada bloque del flujo; representa una tarea. Un **trigger** es el nodo que inicia el flujo, como `Chat Trigger` cuando alguien escribe una pregunta. Una **credencial** guarda de forma protegida los datos de conexión, como el usuario y contraseña de MySQL o una clave de API de un modelo de IA. Es importante no incluir claves reales en las capturas ni en el archivo exportado.

Un **chatbot normal** normalmente responde basándose en lo que ya sabe o en un guion. Un **agente de IA** puede decidir usar una herramienta para conseguir datos antes de responder. En n8n, el nodo AI Agent puede conectarse con un modelo, memoria y herramientas [4]. En nuestro caso, la herramienta será la consulta a MySQL.

Un **LLM** (*Large Language Model* o modelo de lenguaje grande) es el modelo que entiende la pregunta y redacta la respuesta. Las **tools** o herramientas son acciones externas que el agente puede utilizar, como consultar una base de datos. El LLM no debe inventar el inventario: debe pedir los datos a la herramienta cuando la pregunta dependa de la base.

Para hacerlo de forma segura, se debe crear en MySQL un usuario exclusivo para el agente con permiso de solo lectura. Así el agente podrá ejecutar `SELECT`, pero no `INSERT`, `UPDATE`, `DELETE`, `DROP` ni cambios de estructura. Además, el mensaje de sistema debe recordarle que solo use consultas de lectura y que responda cuando no encuentre resultados, sin inventarlos.

## D. Conceptos del dominio aduanero

Una **aduana** es la institución que controla la entrada y salida de mercancías de un país. Entre sus tareas están revisar documentos, aplicar normas, calcular tributos y decidir si una mercancía puede continuar o debe quedar retenida.

La **declaración aduanera** es el documento o registro donde se informa formalmente qué mercancía se mueve, de dónde viene, quién la importa o exporta, qué régimen usa y cuál es su valor. En el sistema será muy importante porque conectará al importador, país de origen, agente aduanal, productos y contenedores.

Una **partida arancelaria** es el código que clasifica una mercancía. El Sistema Armonizado (HS) de la Organización Mundial de Aduanas agrupa productos con códigos de seis dígitos y se usa como base para aranceles y estadísticas internacionales [5]. El **arancel** es el tributo que se cobra a ciertos productos al entrar al país. Puede calcularse como un porcentaje del valor o como una cantidad fija según la mercancía.

Los regímenes básicos son:

- **Importación:** entrada de mercancías al país.
- **Exportación:** salida de mercancías hacia otro país.
- **Tránsito:** la mercancía pasa por el país rumbo a otro destino.
- **Depósito:** la mercancía permanece bajo control aduanero en una bodega o depósito autorizado antes de que se defina su destino.

El **agente aduanal** es una persona o empresa autorizada que representa al importador o exportador ante la aduana. Ayuda a preparar y tramitar la declaración y los documentos requeridos.

## Análisis del caso y requisitos identificados

De acuerdo con el enunciado, la base debe permitir registrar y consultar como mínimo: países, importadores o exportadores, agentes aduanales, productos, partidas arancelarias, declaraciones, sus detalles, contenedores, bodegas, existencias, movimientos, inspecciones y funcionarios. No todas estas entidades tienen que ser idénticas a las sugeridas, pero el diseño debe tener al menos ocho y ser coherente.

El sistema debe responder preguntas como estas:

- ¿Qué mercancías de China siguen retenidas en una bodega específica?
- ¿Cuántas declaraciones de importación se registraron durante un mes?
- ¿Qué importador declaró el mayor valor total?
- ¿Qué inspecciones tuvieron observaciones y qué funcionario las hizo?

Por eso se necesitarán fechas, estados, cantidades, valores, ubicaciones y relaciones entre las entidades. En la siguiente fase se convertirán estos requisitos en un DER lógico, pero todavía no se dibujará ni se escribirá el script SQL.

## Uso de IA durante la investigación

Se utilizó ChatGPT/Codex como apoyo para leer el enunciado, ordenar los temas de investigación y recibir explicaciones en un lenguaje de principiante. Un ejemplo de prompt utilizado fue: “Explícame qué es una llave foránea con un ejemplo de una aduana”.

Lo aprendido fue que la IA puede servir para entender conceptos, generar ejemplos y revisar ideas, pero se debe comprobar la información con fuentes y poder explicar cada parte. La estructura final de la base de datos, el diagrama y las pruebas deben ser comprendidos por el estudiante.

## Fuentes consultadas

1. PostgreSQL Global Development Group. [Constraints — PostgreSQL Documentation](https://www.postgresql.org/docs/current/ddl-constraints.html).
2. SQLite. [SQLite Foreign Key Support](https://www.sqlite.org/foreignkeys.html).
3. n8n. [MySQL node documentation](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.mysql/).
4. n8n. [Key concepts glossary: AI Agent node](https://docs.n8n.io/get-started/key-concepts/).
5. World Customs Organization. [What is the Harmonized System (HS)?](https://www.wcoomd.org/en/topics/nomenclature/overview/what-is-the-harmonized-system.aspx).

