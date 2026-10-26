# Fase 2 — Diseño lógico del DER

## Idea general del diseño

La aduana necesita saber quién declara la mercancía, de qué país viene, qué productos contiene, dónde se guardan, qué movimientos tienen y si fueron inspeccionados. Para que esa información no quede repetida, se separó en entidades pequeñas y relacionadas.

Se usarán **13 entidades**. Esto supera el mínimo de 8 que pide el laboratorio. La propuesta está pensada para MySQL, pero en esta fase todavía no se escribe SQL ejecutable.

## Leyenda para el dibujo

- **PK**: llave primaria; identifica una fila de forma única.
- **FK**: llave foránea; conecta una tabla con otra.
- **NN**: campo obligatorio (`NOT NULL` en SQL).
- En pata de gallo: `1` significa uno y la pata significa muchos.

> Consejo: en el DER hecho a mano puedes escribir primero el nombre de la entidad en la parte superior del rectángulo. Debajo coloca sus atributos, marcando PK y FK. No es necesario dibujar todos los tipos de datos con un tamaño de letra grande, pero sí deben aparecer.

## Entidades y atributos

### 1. País

Representa el país de origen declarado de la mercancía.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_pais | INT | PK | Identificador del país. |
| nombre | VARCHAR(60) | NN, UNIQUE | Nombre del país. |
| codigo_iso | CHAR(2) | NN, UNIQUE | Código de dos letras, por ejemplo `CN`. |

### 2. Operador comercial

En vez de crear por separado importador y exportador, esta entidad cubre ambos casos. Un mismo negocio puede importar y exportar, por eso es más práctico guardarlo una vez.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_operador | INT | PK | Identificador del operador. |
| razon_social | VARCHAR(120) | NN | Nombre de la empresa o persona. |
| nit_ruc | VARCHAR(25) | NN, UNIQUE | Identificación tributaria. |
| tipo_operador | VARCHAR(15) | NN | Importador, Exportador o Ambos. |
| direccion | VARCHAR(180) |  | Dirección. |
| telefono | VARCHAR(20) |  | Teléfono. |
| correo | VARCHAR(100) | UNIQUE | Correo electrónico. |

### 3. Agente aduanal

Representa al profesional o empresa que tramita documentos ante la aduana.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_agente | INT | PK | Identificador del agente. |
| nombre | VARCHAR(100) | NN | Nombre completo. |
| licencia | VARCHAR(30) | NN, UNIQUE | Número de licencia. |
| telefono | VARCHAR(20) |  | Teléfono de contacto. |
| correo | VARCHAR(100) | UNIQUE | Correo de contacto. |

### 4. Partida arancelaria

Clasifica el producto y permite guardar el porcentaje de arancel que normalmente le corresponde.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_partida | INT | PK | Identificador interno. |
| codigo_hs | CHAR(6) | NN, UNIQUE | Código de seis dígitos del Sistema Armonizado. |
| descripcion | VARCHAR(180) | NN | Descripción de la partida. |
| porcentaje_arancel | DECIMAL(5,2) | NN | Porcentaje aplicado; por ejemplo, 15.00. |

### 5. Producto

Guarda la mercancía que puede aparecer dentro de una declaración.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_producto | INT | PK | Identificador del producto. |
| descripcion | VARCHAR(180) | NN | Nombre o descripción del producto. |
| unidad_medida | VARCHAR(20) | NN | Unidad como unidad, caja, kg o litro. |
| valor_unitario | DECIMAL(12,2) | NN | Valor de una unidad. |
| id_partida | INT | FK, NN | Partida arancelaria del producto. |

### 6. Declaración aduanera

Es el registro central del trámite. Indica quién declara, el agente responsable, el país de origen y el tipo de régimen.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_declaracion | INT | PK | Identificador de la declaración. |
| numero | VARCHAR(25) | NN, UNIQUE | Número visible de la declaración. |
| fecha | DATE | NN | Fecha de registro. |
| regimen | VARCHAR(15) | NN | Importación, Exportación, Tránsito o Depósito. |
| estado | VARCHAR(15) | NN | Pendiente, Retenida, Liberada o Cerrada. |
| id_operador | INT | FK, NN | Operador que presenta la declaración. |
| id_agente | INT | FK, NN | Agente aduanal que la tramita. |
| id_pais_origen | INT | FK, NN | País de origen de la mercancía. |

### 7. Detalle de declaración

Esta es la tabla intermedia que resuelve la relación **N:M** entre declaración y producto. También contiene datos que dependen de esa relación, como la cantidad y el valor declarado.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_detalle | INT | PK | Identificador del detalle. |
| id_declaracion | INT | FK, NN | Declaración a la que pertenece. |
| id_producto | INT | FK, NN | Producto declarado. |
| cantidad | DECIMAL(12,2) | NN | Cantidad del producto. |
| valor_declarado | DECIMAL(14,2) | NN | Valor total declarado para esa línea. |

**Regla recomendada:** la combinación `(id_declaracion, id_producto)` debe ser `UNIQUE` para no registrar el mismo producto dos veces en la misma declaración.

### 8. Contenedor

Registra el contenedor físico relacionado con una declaración.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_contenedor | INT | PK | Identificador interno. |
| numero_contenedor | VARCHAR(20) | NN, UNIQUE | Código del contenedor. |
| tipo | VARCHAR(20) | NN | Por ejemplo: seco, refrigerado o tanque. |
| peso_kg | DECIMAL(12,2) | NN | Peso registrado en kilogramos. |
| id_declaracion | INT | FK, NN | Declaración relacionada. |

### 9. Bodega

Es el lugar físico donde se guarda la mercancía bajo control de la aduana.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_bodega | INT | PK | Identificador de la bodega. |
| nombre | VARCHAR(80) | NN, UNIQUE | Nombre, por ejemplo “Bodega 2”. |
| ubicacion | VARCHAR(150) | NN | Ubicación física. |
| capacidad_kg | DECIMAL(12,2) | NN | Capacidad máxima en kg. |

### 10. Inventario

Representa un lote de mercancía de una línea de declaración que se encuentra en una bodega. Se relaciona con `detalle_declaracion` para saber exactamente de cuál declaración y producto viene; por eso no necesita repetir `id_producto`.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_inventario | INT | PK | Identificador del lote en bodega. |
| id_bodega | INT | FK, NN | Bodega donde está guardado. |
| id_detalle | INT | FK, NN | Detalle que indica producto y declaración de origen. |
| cantidad_actual | DECIMAL(12,2) | NN | Cantidad disponible en ese lote. |
| fecha_ingreso | DATE | NN | Fecha de entrada a la bodega. |
| estado | VARCHAR(15) | NN | Retenido, Liberado o En inspección. |

**Regla recomendada:** `(id_bodega, id_detalle)` debe ser `UNIQUE`. Así, un detalle de declaración tiene un solo registro de stock por bodega, sin duplicados.

### 11. Movimiento de inventario

Guarda el historial de entradas, salidas y ajustes. Para un traslado se pueden registrar dos movimientos: salida del inventario de origen y entrada en el inventario de destino. Es más fácil de entender y evita modificar el historial anterior.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_movimiento | INT | PK | Identificador del movimiento. |
| id_inventario | INT | FK, NN | Lote de inventario afectado. |
| tipo | VARCHAR(15) | NN | Entrada, Salida o Ajuste. |
| fecha_movimiento | DATETIME | NN | Fecha y hora del movimiento. |
| cantidad | DECIMAL(12,2) | NN | Cantidad movida. |
| observacion | VARCHAR(200) |  | Nota breve del movimiento. |

### 12. Funcionario

Guarda a los funcionarios que pueden realizar inspecciones. Tiene una relación recursiva: un funcionario puede tener como supervisor a otro funcionario.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_funcionario | INT | PK | Identificador del funcionario. |
| nombre | VARCHAR(100) | NN | Nombre completo. |
| cargo | VARCHAR(60) | NN | Cargo, por ejemplo inspector o supervisor. |
| telefono | VARCHAR(20) |  | Teléfono. |
| id_supervisor | INT | FK, puede ser NULL | Funcionario que lo supervisa. |

### 13. Inspección

Registra una revisión hecha a una declaración y el funcionario responsable.

| Atributo | Tipo sugerido | Marca | Explicación |
|---|---|---|---|
| id_inspeccion | INT | PK | Identificador de la inspección. |
| id_declaracion | INT | FK, NN | Declaración revisada. |
| id_funcionario | INT | FK, NN | Funcionario que hizo la inspección. |
| fecha_inspeccion | DATE | NN | Fecha de la revisión. |
| resultado | VARCHAR(30) | NN | Aprobada, Con observaciones o Rechazada. |
| observaciones | TEXT |  | Detalle de los hallazgos. |

## Relaciones y cardinalidades

Estas son las líneas que debes dibujar entre las entidades:

| Relación | Cardinalidad | Cómo entenderla |
|---|---|---|
| País — Declaración | 1:N | Un país puede aparecer como origen de muchas declaraciones; cada declaración tiene un país de origen. |
| Operador comercial — Declaración | 1:N | Un operador puede realizar muchas declaraciones; cada declaración pertenece a un operador. |
| Agente aduanal — Declaración | 1:N | Un agente puede tramitar muchas declaraciones; cada declaración registra un agente. |
| Partida arancelaria — Producto | 1:N | Una partida clasifica muchos productos; un producto tiene una partida. |
| Declaración — Detalle de declaración | 1:N | Una declaración tiene varias líneas de detalle; cada detalle pertenece a una declaración. |
| Producto — Detalle de declaración | 1:N | Un producto puede aparecer en varios detalles; cada detalle indica un producto. |
| Declaración — Producto | N:M, mediante Detalle de declaración | Una declaración puede incluir varios productos y un producto puede estar en varias declaraciones. |
| Declaración — Contenedor | 1:N | Una declaración puede tener uno o varios contenedores; cada contenedor se asocia con una declaración. |
| Bodega — Inventario | 1:N | Una bodega contiene varios lotes de inventario; cada lote está en una bodega. |
| Detalle de declaración — Inventario | 1:N | Una línea declarada puede quedar repartida en más de una bodega; cada lote proviene de un detalle. |
| Inventario — Movimiento de inventario | 1:N | Un lote puede tener muchos movimientos; cada movimiento afecta un lote. |
| Declaración — Inspección | 1:N | Una declaración puede ser inspeccionada más de una vez; cada inspección corresponde a una declaración. |
| Funcionario — Inspección | 1:N | Un funcionario puede realizar muchas inspecciones; cada inspección la realiza un funcionario. |
| Funcionario — Funcionario | 1:N recursiva | Un supervisor puede tener varios funcionarios a cargo; un funcionario tiene cero o un supervisor. |

## Cómo dibujarlo a mano

1. Usa una hoja horizontal. Escribe **Declaración aduanera** aproximadamente en el centro, porque es la entidad que más se conecta.
2. A la izquierda coloca **País**, **Operador comercial** y **Agente aduanal**. Une cada una con Declaración y marca `1` de su lado y pata de gallo del lado de Declaración.
3. Arriba o a la derecha de Declaración coloca **Detalle de declaración**. A su derecha coloca **Producto** y, más a la derecha, **Partida arancelaria**. Las dos líneas que llegan a Detalle muestran visualmente la N:M entre Declaración y Producto.
4. Debajo de Declaración coloca **Contenedor** e **Inspección**. A la derecha de Inspección coloca **Funcionario**. Dibuja una línea que sale de Funcionario y vuelve a Funcionario para representar `id_supervisor`.
5. En la parte inferior izquierda coloca **Bodega**, después **Inventario** y después **Movimiento de inventario**. Conecta Detalle de declaración con Inventario, para conservar el origen de la mercancía.
6. Dentro de cada rectángulo subraya o escribe `PK` junto al identificador. Escribe `FK` junto a los campos que se conectan con otra entidad.
7. Revisa que cada FK que escribiste tenga su entidad padre dibujada. Si ves `id_producto` en Detalle, debe existir la entidad Producto; si ves `id_detalle` en Inventario, debe existir Detalle de declaración.

## Borrador en sintaxis DBML (opcional)

Este bloque no reemplaza el dibujo manual. Se puede pegar en dbdiagram.io solo para verificar que las relaciones tienen sentido y luego usarlo como guía para trazarlo de forma natural.

```dbml
Table pais {
  id_pais int [pk]
  nombre varchar [not null, unique]
  codigo_iso char(2) [not null, unique]
}

Table operador_comercial {
  id_operador int [pk]
  razon_social varchar [not null]
  nit_ruc varchar [not null, unique]
  tipo_operador varchar [not null]
  direccion varchar
  telefono varchar
  correo varchar [unique]
}

Table agente_aduanal {
  id_agente int [pk]
  nombre varchar [not null]
  licencia varchar [not null, unique]
  telefono varchar
  correo varchar [unique]
}

Table partida_arancelaria {
  id_partida int [pk]
  codigo_hs char(6) [not null, unique]
  descripcion varchar [not null]
  porcentaje_arancel decimal [not null]
}

Table producto {
  id_producto int [pk]
  descripcion varchar [not null]
  unidad_medida varchar [not null]
  valor_unitario decimal [not null]
  id_partida int [not null]
}

Table declaracion_aduanera {
  id_declaracion int [pk]
  numero varchar [not null, unique]
  fecha date [not null]
  regimen varchar [not null]
  estado varchar [not null]
  id_operador int [not null]
  id_agente int [not null]
  id_pais_origen int [not null]
}

Table detalle_declaracion {
  id_detalle int [pk]
  id_declaracion int [not null]
  id_producto int [not null]
  cantidad decimal [not null]
  valor_declarado decimal [not null]

  indexes { (id_declaracion, id_producto) [unique] }
}

Table contenedor {
  id_contenedor int [pk]
  numero_contenedor varchar [not null, unique]
  tipo varchar [not null]
  peso_kg decimal [not null]
  id_declaracion int [not null]
}

Table bodega {
  id_bodega int [pk]
  nombre varchar [not null, unique]
  ubicacion varchar [not null]
  capacidad_kg decimal [not null]
}

Table inventario {
  id_inventario int [pk]
  id_bodega int [not null]
  id_detalle int [not null]
  cantidad_actual decimal [not null]
  fecha_ingreso date [not null]
  estado varchar [not null]

  indexes { (id_bodega, id_detalle) [unique] }
}

Table movimiento_inventario {
  id_movimiento int [pk]
  id_inventario int [not null]
  tipo varchar [not null]
  fecha_movimiento datetime [not null]
  cantidad decimal [not null]
  observacion varchar
}

Table funcionario {
  id_funcionario int [pk]
  nombre varchar [not null]
  cargo varchar [not null]
  telefono varchar
  id_supervisor int
}

Table inspeccion {
  id_inspeccion int [pk]
  id_declaracion int [not null]
  id_funcionario int [not null]
  fecha_inspeccion date [not null]
  resultado varchar [not null]
  observaciones text
}

Ref: declaracion_aduanera.id_pais_origen > pais.id_pais
Ref: declaracion_aduanera.id_operador > operador_comercial.id_operador
Ref: declaracion_aduanera.id_agente > agente_aduanal.id_agente
Ref: producto.id_partida > partida_arancelaria.id_partida
Ref: detalle_declaracion.id_declaracion > declaracion_aduanera.id_declaracion
Ref: detalle_declaracion.id_producto > producto.id_producto
Ref: contenedor.id_declaracion > declaracion_aduanera.id_declaracion
Ref: inventario.id_bodega > bodega.id_bodega
Ref: inventario.id_detalle > detalle_declaracion.id_detalle
Ref: movimiento_inventario.id_inventario > inventario.id_inventario
Ref: inspeccion.id_declaracion > declaracion_aduanera.id_declaracion
Ref: inspeccion.id_funcionario > funcionario.id_funcionario
Ref: funcionario.id_supervisor > funcionario.id_funcionario
```

## Validación antes de pasar al SQL

- Hay 13 entidades y cada una tiene PK.
- Hay muchas relaciones 1:N.
- La relación N:M entre Declaración y Producto está resuelta por `detalle_declaracion`.
- Hay una relación recursiva: Funcionario supervisa a Funcionario.
- No se repite el país, importador, agente o descripción de partida dentro de cada declaración.
- El inventario conserva la relación con la mercancía original usando `id_detalle`.

