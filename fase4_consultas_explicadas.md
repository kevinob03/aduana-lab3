# Fase 4 — Consultas SQL analíticas

Las ocho consultas ya están al final de `Aduana_Lab3.sql`. Este documento sirve para entender qué pregunta responde cada una antes de ejecutarla.

| # | Pregunta que responde | Conceptos principales |
|---|---|---|
| 1 | ¿Cuántas declaraciones de importación se registraron en octubre? | `JOIN`, `WHERE`, `COUNT`, `GROUP BY` |
| 2 | ¿Qué mercancías siguen retenidas y en qué bodega están? | Varios `JOIN`, `WHERE`, `ORDER BY` |
| 3 | ¿Cuál país tiene más contenedores de importación? | `JOIN`, `COUNT`, `GROUP BY`, `LIMIT` |
| 4 | ¿Qué operador declaró el mayor valor de importación? | `JOIN`, `SUM`, `GROUP BY`, `LIMIT` |
| 5 | ¿Qué inspecciones tuvieron observaciones y quién las realizó? | `JOIN`, `WHERE`, `ORDER BY` |
| 6 | ¿Cuánto stock queda de un producto en cada bodega? | `JOIN`, `WHERE`, `SUM`, `GROUP BY` |
| 7 | ¿Cuál es el valor retenido por país de origen? | `JOIN`, `WHERE`, `SUM`, `GROUP BY` |
| 8 | ¿Cuánto inventario ingresó a cada bodega en octubre? | `JOIN`, `WHERE`, `COUNT`, `SUM`, `GROUP BY` |

## Recordatorio sencillo

- `JOIN` une datos de tablas relacionadas. Por ejemplo, une inventario con producto para mostrar el nombre del producto en vez de solo su identificador.
- `WHERE` filtra antes de calcular. Por ejemplo, deja solo los registros que están retenidos.
- `GROUP BY` reúne filas parecidas para calcular un total, como el total por país o por bodega.
- `ORDER BY` organiza los resultados para que los más importantes aparezcan primero.

Para ejecutar una consulta en MySQL Workbench, primero se ejecuta todo el script de creación y datos. Después se puede seleccionar solamente una de las consultas del final y presionar el botón de ejecutar. Así se observa el resultado de cada pregunta por separado.
