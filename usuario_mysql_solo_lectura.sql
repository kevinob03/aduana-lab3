-- Usuario de MySQL para el agente de n8n.
-- Ejecutar este archivo como administrador de MySQL DESPUES de crear aduana_lab3.
-- Reemplaza la contrasena de ejemplo antes de ejecutarlo.

CREATE USER IF NOT EXISTS 'agente_aduana_lectura'@'localhost'
IDENTIFIED BY 'CAMBIAR_POR_UNA_CLAVE_LARGA_Y_PRIVADA';

GRANT SELECT ON aduana_lab3.* TO 'agente_aduana_lectura'@'localhost';

-- Verificacion opcional: debe mostrar solamente SELECT sobre aduana_lab3.
SHOW GRANTS FOR 'agente_aduana_lectura'@'localhost';

-- Si n8n esta en otra computadora o en Docker, NO uses % sin pensarlo.
-- Crea un usuario equivalente cambiando localhost por la IP o red exacta de n8n.
