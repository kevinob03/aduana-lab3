-- Laboratorio #3 | Sistema de inventario para una aduana
-- Integrante(s): ________________________________
-- Gestor utilizado: MySQL 8.0 o superior
-- Fecha: 2026-10-25
--
-- Nota: ejecutar este archivo completo en una instancia MySQL vacía.
-- Las consultas analíticas se harán por separado en la Fase 4.

CREATE DATABASE IF NOT EXISTS aduana_lab3
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE aduana_lab3;

-- =========================================================
-- 1. TABLAS PRINCIPALES (sin dependencias)
-- =========================================================

CREATE TABLE pais (
    id_pais INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    codigo_iso CHAR(2) NOT NULL UNIQUE
);

CREATE TABLE operador_comercial (
    id_operador INT AUTO_INCREMENT PRIMARY KEY,
    razon_social VARCHAR(120) NOT NULL,
    nit_ruc VARCHAR(25) NOT NULL UNIQUE,
    tipo_operador VARCHAR(15) NOT NULL,
    direccion VARCHAR(180),
    telefono VARCHAR(20),
    correo VARCHAR(100) UNIQUE,
    CONSTRAINT chk_tipo_operador
        CHECK (tipo_operador IN ('Importador', 'Exportador', 'Ambos'))
);

CREATE TABLE agente_aduanal (
    id_agente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    licencia VARCHAR(30) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(100) UNIQUE
);

CREATE TABLE partida_arancelaria (
    id_partida INT AUTO_INCREMENT PRIMARY KEY,
    codigo_hs CHAR(6) NOT NULL UNIQUE,
    descripcion VARCHAR(180) NOT NULL,
    porcentaje_arancel DECIMAL(5,2) NOT NULL,
    CONSTRAINT chk_porcentaje_arancel
        CHECK (porcentaje_arancel BETWEEN 0 AND 100)
);

CREATE TABLE bodega (
    id_bodega INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    ubicacion VARCHAR(150) NOT NULL,
    capacidad_kg DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_capacidad_bodega CHECK (capacidad_kg > 0)
);

CREATE TABLE funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(60) NOT NULL,
    telefono VARCHAR(20),
    id_supervisor INT NULL,
    CONSTRAINT fk_funcionario_supervisor
        FOREIGN KEY (id_supervisor) REFERENCES funcionario(id_funcionario),
    CONSTRAINT chk_supervisor_distinto
        CHECK (id_supervisor IS NULL OR id_supervisor <> id_funcionario)
);

-- =========================================================
-- 2. TABLAS RELACIONADAS
-- =========================================================

CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(180) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL,
    valor_unitario DECIMAL(12,2) NOT NULL,
    id_partida INT NOT NULL,
    CONSTRAINT fk_producto_partida
        FOREIGN KEY (id_partida) REFERENCES partida_arancelaria(id_partida),
    CONSTRAINT chk_valor_unitario CHECK (valor_unitario >= 0)
);

CREATE TABLE declaracion_aduanera (
    id_declaracion INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(25) NOT NULL UNIQUE,
    fecha DATE NOT NULL,
    regimen VARCHAR(15) NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'Pendiente',
    id_operador INT NOT NULL,
    id_agente INT NOT NULL,
    id_pais_origen INT NOT NULL,
    CONSTRAINT fk_declaracion_operador
        FOREIGN KEY (id_operador) REFERENCES operador_comercial(id_operador),
    CONSTRAINT fk_declaracion_agente
        FOREIGN KEY (id_agente) REFERENCES agente_aduanal(id_agente),
    CONSTRAINT fk_declaracion_pais
        FOREIGN KEY (id_pais_origen) REFERENCES pais(id_pais),
    CONSTRAINT chk_regimen
        CHECK (regimen IN ('Importacion', 'Exportacion', 'Transito', 'Deposito')),
    CONSTRAINT chk_estado_declaracion
        CHECK (estado IN ('Pendiente', 'Retenida', 'Liberada', 'Cerrada', 'En transito'))
);

CREATE TABLE detalle_declaracion (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_declaracion INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    valor_declarado DECIMAL(14,2) NOT NULL,
    CONSTRAINT fk_detalle_declaracion
        FOREIGN KEY (id_declaracion) REFERENCES declaracion_aduanera(id_declaracion),
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    CONSTRAINT uq_detalle_declaracion_producto UNIQUE (id_declaracion, id_producto),
    CONSTRAINT chk_cantidad_detalle CHECK (cantidad > 0),
    CONSTRAINT chk_valor_declarado CHECK (valor_declarado >= 0)
);

CREATE TABLE contenedor (
    id_contenedor INT AUTO_INCREMENT PRIMARY KEY,
    numero_contenedor VARCHAR(20) NOT NULL UNIQUE,
    tipo VARCHAR(20) NOT NULL,
    peso_kg DECIMAL(12,2) NOT NULL,
    id_declaracion INT NOT NULL,
    CONSTRAINT fk_contenedor_declaracion
        FOREIGN KEY (id_declaracion) REFERENCES declaracion_aduanera(id_declaracion),
    CONSTRAINT chk_tipo_contenedor
        CHECK (tipo IN ('Seco', 'Refrigerado', 'Tanque', 'Plataforma')),
    CONSTRAINT chk_peso_contenedor CHECK (peso_kg > 0)
);

CREATE TABLE inventario (
    id_inventario INT AUTO_INCREMENT PRIMARY KEY,
    id_bodega INT NOT NULL,
    id_detalle INT NOT NULL,
    cantidad_actual DECIMAL(12,2) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'Retenido',
    CONSTRAINT fk_inventario_bodega
        FOREIGN KEY (id_bodega) REFERENCES bodega(id_bodega),
    CONSTRAINT fk_inventario_detalle
        FOREIGN KEY (id_detalle) REFERENCES detalle_declaracion(id_detalle),
    CONSTRAINT uq_inventario_bodega_detalle UNIQUE (id_bodega, id_detalle),
    CONSTRAINT chk_cantidad_actual CHECK (cantidad_actual >= 0),
    CONSTRAINT chk_estado_inventario
        CHECK (estado IN ('Retenido', 'Liberado', 'En inspeccion'))
);

CREATE TABLE movimiento_inventario (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_inventario INT NOT NULL,
    tipo VARCHAR(15) NOT NULL,
    fecha_movimiento DATETIME NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    observacion VARCHAR(200),
    CONSTRAINT fk_movimiento_inventario
        FOREIGN KEY (id_inventario) REFERENCES inventario(id_inventario),
    CONSTRAINT chk_tipo_movimiento
        CHECK (tipo IN ('Entrada', 'Salida', 'Ajuste')),
    CONSTRAINT chk_cantidad_movimiento CHECK (cantidad > 0)
);

CREATE TABLE inspeccion (
    id_inspeccion INT AUTO_INCREMENT PRIMARY KEY,
    id_declaracion INT NOT NULL,
    id_funcionario INT NOT NULL,
    fecha_inspeccion DATE NOT NULL,
    resultado VARCHAR(30) NOT NULL,
    observaciones TEXT,
    CONSTRAINT fk_inspeccion_declaracion
        FOREIGN KEY (id_declaracion) REFERENCES declaracion_aduanera(id_declaracion),
    CONSTRAINT fk_inspeccion_funcionario
        FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
    CONSTRAINT chk_resultado_inspeccion
        CHECK (resultado IN ('Aprobada', 'Con observaciones', 'Rechazada'))
);

-- =========================================================
-- 3. DATOS DE PRUEBA: 15 o más registros por tabla
-- =========================================================

INSERT INTO pais (nombre, codigo_iso) VALUES
('China', 'CN'),
('Estados Unidos', 'US'),
('Alemania', 'DE'),
('Japon', 'JP'),
('Mexico', 'MX'),
('Brasil', 'BR'),
('Espana', 'ES'),
('Corea del Sur', 'KR'),
('Italia', 'IT'),
('India', 'IN'),
('Canada', 'CA'),
('Panama', 'PA'),
('Chile', 'CL'),
('Francia', 'FR'),
('Costa Rica', 'CR');

INSERT INTO operador_comercial
(razon_social, nit_ruc, tipo_operador, direccion, telefono, correo) VALUES
('Importadora Tica S.A.', '3-101-100001', 'Importador', 'San Jose, La Uruca', '2201-1001', 'contacto@tica.cr'),
('Comercial Pacifico Ltda.', '3-101-100002', 'Importador', 'Puntarenas, Caldera', '2201-1002', 'ventas@pacifico.cr'),
('Tecnologia Central S.A.', '3-101-100003', 'Importador', 'Heredia, Belen', '2201-1003', 'info@tecnocentral.cr'),
('Alimentos del Valle S.A.', '3-101-100004', 'Importador', 'Alajuela, Grecia', '2201-1004', 'info@alimentosvalle.cr'),
('Automotriz del Istmo S.A.', '3-101-100005', 'Importador', 'San Jose, Curridabat', '2201-1005', 'ventas@autoistmo.cr'),
('Textiles Monte Azul S.A.', '3-101-100006', 'Importador', 'Cartago, Paraiso', '2201-1006', 'info@monteazul.cr'),
('Distribuidora Nacional S.A.', '3-101-100007', 'Importador', 'San Jose, Tibas', '2201-1007', 'contacto@disnacional.cr'),
('Juguetes y Mas Ltda.', '3-101-100008', 'Importador', 'Heredia, Santo Domingo', '2201-1008', 'ventas@juguetesymas.cr'),
('Importaciones del Caribe S.A.', '3-101-100009', 'Importador', 'Limon, Centro', '2201-1009', 'info@caribe.cr'),
('Construcciones Modernas S.A.', '3-101-100010', 'Importador', 'San Jose, Pavas', '2201-1010', 'info@construcciones.cr'),
('Farmacia Vida S.A.', '3-101-100011', 'Importador', 'Alajuela, Centro', '2201-1011', 'compras@vidacr.com'),
('Llantas Seguras Ltda.', '3-101-100012', 'Importador', 'San Jose, Desamparados', '2201-1012', 'info@llantasseguras.cr'),
('Exportadora Tropical S.A.', '3-101-100013', 'Exportador', 'Limon, Guapiles', '2201-1013', 'ventas@tropical.cr'),
('Comercio Internacional CR S.A.', '3-101-100014', 'Ambos', 'Heredia, Barva', '2201-1014', 'info@cominternacional.cr'),
('Mercancias Unidas S.A.', '3-101-100015', 'Ambos', 'Cartago, Oreamuno', '2201-1015', 'contacto@unidas.cr');

INSERT INTO agente_aduanal (nombre, licencia, telefono, correo) VALUES
('Laura Mendez Rojas', 'AGA-001', '2250-2001', 'laura.mendez@agentes.cr'),
('Carlos Vargas Soto', 'AGA-002', '2250-2002', 'carlos.vargas@agentes.cr'),
('Sofia Jimenez Mora', 'AGA-003', '2250-2003', 'sofia.jimenez@agentes.cr'),
('Daniel Araya Castro', 'AGA-004', '2250-2004', 'daniel.araya@agentes.cr'),
('Ana Solano Ruiz', 'AGA-005', '2250-2005', 'ana.solano@agentes.cr'),
('Miguel Quesada Leon', 'AGA-006', '2250-2006', 'miguel.quesada@agentes.cr'),
('Paula Chaves Vega', 'AGA-007', '2250-2007', 'paula.chaves@agentes.cr'),
('Andres Cordero Diaz', 'AGA-008', '2250-2008', 'andres.cordero@agentes.cr'),
('Valeria Brenes Rojas', 'AGA-009', '2250-2009', 'valeria.brenes@agentes.cr'),
('Jorge Salas Mora', 'AGA-010', '2250-2010', 'jorge.salas@agentes.cr'),
('Natalia Campos Solis', 'AGA-011', '2250-2011', 'natalia.campos@agentes.cr'),
('Ricardo Urena Soto', 'AGA-012', '2250-2012', 'ricardo.urena@agentes.cr'),
('Gabriela Porras Leon', 'AGA-013', '2250-2013', 'gabriela.porras@agentes.cr'),
('Esteban Rojas Arias', 'AGA-014', '2250-2014', 'esteban.rojas@agentes.cr'),
('Mariana Castro Vega', 'AGA-015', '2250-2015', 'mariana.castro@agentes.cr');

INSERT INTO partida_arancelaria (codigo_hs, descripcion, porcentaje_arancel) VALUES
('847130', 'Maquinas portatiles para procesamiento de datos', 10.00),
('851713', 'Telefonos inteligentes', 13.00),
('940360', 'Los demas muebles de madera', 15.00),
('850440', 'Convertidores estaticos y adaptadores', 5.00),
('300490', 'Medicamentos preparados para usos terapeuticos', 2.00),
('870323', 'Automoviles con motor de cilindrada media', 30.00),
('640399', 'Calzado con suela de caucho o plastico', 18.00),
('620342', 'Pantalones de algodon para hombre', 15.00),
('020230', 'Carne bovina congelada deshuesada', 12.00),
('100630', 'Arroz semiblanqueado o blanqueado', 35.00),
('220300', 'Cerveza de malta', 20.00),
('330499', 'Preparaciones de belleza o maquillaje', 15.00),
('401110', 'Neumaticos nuevos para automoviles', 10.00),
('730890', 'Construcciones y partes de hierro o acero', 8.00),
('950300', 'Juguetes y modelos reducidos', 12.00);

INSERT INTO producto (descripcion, unidad_medida, valor_unitario, id_partida) VALUES
('Computadora portatil de 14 pulgadas', 'unidad', 900.00, 1),
('Telefono inteligente de 128 GB', 'unidad', 300.00, 2),
('Escritorio de madera', 'unidad', 600.00, 3),
('Adaptador de corriente USB-C', 'unidad', 18.00, 4),
('Medicamento analgesico en tabletas', 'caja', 15.00, 5),
('Automovil sedan', 'unidad', 28000.00, 6),
('Zapato deportivo', 'par', 35.00, 7),
('Pantalon de algodon', 'unidad', 30.00, 8),
('Carne bovina congelada', 'kg', 5.50, 9),
('Arroz blanco', 'kg', 1.80, 10),
('Cerveza artesanal', 'botella', 1.20, 11),
('Crema hidratante', 'unidad', 15.00, 12),
('Llanta para automovil', 'unidad', 120.00, 13),
('Estructura metalica prefabricada', 'unidad', 500.00, 14),
('Juguete de construccion', 'unidad', 5.00, 15);

INSERT INTO bodega (nombre, ubicacion, capacidad_kg) VALUES
('Bodega 1', 'Puerto Caldera, zona A', 50000.00),
('Bodega 2', 'Puerto Caldera, zona B', 45000.00),
('Bodega 3', 'Puerto Caldera, zona C', 60000.00),
('Bodega 4', 'Aduana Central, edificio norte', 35000.00),
('Bodega 5', 'Aduana Central, edificio sur', 30000.00),
('Bodega 6', 'Paso Canoas, zona primaria', 40000.00),
('Bodega 7', 'Peñas Blancas, zona primaria', 42000.00),
('Bodega 8', 'Limon, terminal A', 55000.00),
('Bodega 9', 'Limon, terminal B', 55000.00),
('Bodega 10', 'San Jose, deposito fiscal 1', 25000.00),
('Bodega 11', 'San Jose, deposito fiscal 2', 25000.00),
('Bodega 12', 'Heredia, zona logistica', 28000.00),
('Bodega 13', 'Alajuela, zona franca', 32000.00),
('Bodega 14', 'Cartago, centro de carga', 26000.00),
('Bodega 15', 'Guanacaste, deposito temporal', 20000.00);

INSERT INTO funcionario (nombre, cargo, telefono, id_supervisor) VALUES
('Roberto Alvarado Mora', 'Jefe de inspeccion', '2400-3001', NULL),
('Elena Rojas Campos', 'Supervisora de turno', '2400-3002', 1),
('Diego Mora Salas', 'Inspector aduanero', '2400-3003', 2),
('Carolina Vega Rojas', 'Inspectora aduanera', '2400-3004', 2),
('Fernando Castro Solis', 'Inspector aduanero', '2400-3005', 2),
('Lucia Araya Mendez', 'Inspectora aduanera', '2400-3006', 2),
('Mario Chaves Soto', 'Supervisor de bodega', '2400-3007', 1),
('Andrea Leon Ruiz', 'Inspectora aduanera', '2400-3008', 7),
('Pablo Jimenez Vega', 'Inspector aduanero', '2400-3009', 7),
('Karla Quesada Mora', 'Inspectora aduanera', '2400-3010', 7),
('Jose Solano Rojas', 'Inspector aduanero', '2400-3011', 7),
('Melissa Vargas Diaz', 'Inspectora aduanera', '2400-3012', 2),
('Hector Brenes Castro', 'Inspector aduanero', '2400-3013', 2),
('Adriana Cordero Leon', 'Inspectora aduanera', '2400-3014', 7),
('Luis Porras Araya', 'Inspector aduanero', '2400-3015', 7);

INSERT INTO declaracion_aduanera
(numero, fecha, regimen, estado, id_operador, id_agente, id_pais_origen) VALUES
('DUA-2026-0001', '2026-10-01', 'Importacion', 'Retenida', 1, 1, 1),
('DUA-2026-0002', '2026-10-02', 'Importacion', 'Liberada', 2, 2, 2),
('DUA-2026-0003', '2026-10-03', 'Importacion', 'En transito', 3, 3, 3),
('DUA-2026-0004', '2026-10-04', 'Importacion', 'Retenida', 4, 4, 4),
('DUA-2026-0005', '2026-10-05', 'Importacion', 'Liberada', 5, 5, 5),
('DUA-2026-0006', '2026-10-06', 'Importacion', 'Pendiente', 6, 6, 6),
('DUA-2026-0007', '2026-10-07', 'Importacion', 'Retenida', 7, 7, 7),
('DUA-2026-0008', '2026-10-08', 'Importacion', 'Liberada', 8, 8, 8),
('DUA-2026-0009', '2026-10-09', 'Importacion', 'Retenida', 9, 9, 1),
('DUA-2026-0010', '2026-10-10', 'Deposito', 'Pendiente', 10, 10, 9),
('DUA-2026-0011', '2026-10-11', 'Importacion', 'Liberada', 11, 11, 10),
('DUA-2026-0012', '2026-10-12', 'Importacion', 'Retenida', 12, 12, 11),
('DUA-2026-0013', '2026-10-13', 'Transito', 'Pendiente', 13, 13, 12),
('DUA-2026-0014', '2026-09-28', 'Importacion', 'Cerrada', 14, 14, 13),
('DUA-2026-0015', '2026-09-30', 'Exportacion', 'Cerrada', 15, 15, 15);

INSERT INTO detalle_declaracion
(id_declaracion, id_producto, cantidad, valor_declarado) VALUES
(1, 1, 50.00, 45000.00), (1, 4, 100.00, 1800.00),
(2, 2, 200.00, 60000.00), (2, 13, 80.00, 9600.00),
(3, 3, 40.00, 24000.00), (3, 14, 25.00, 12500.00),
(4, 5, 500.00, 7500.00), (4, 12, 300.00, 4500.00),
(5, 6, 10.00, 280000.00), (5, 7, 500.00, 17500.00),
(6, 8, 800.00, 24000.00), (6, 10, 1000.00, 1800.00),
(7, 9, 2000.00, 11000.00), (7, 11, 5000.00, 6000.00),
(8, 15, 1000.00, 5000.00), (8, 1, 20.00, 18000.00),
(9, 2, 150.00, 45000.00), (9, 12, 400.00, 6000.00),
(10, 3, 30.00, 18000.00), (10, 4, 250.00, 4500.00),
(11, 5, 300.00, 4500.00), (11, 7, 700.00, 24500.00),
(12, 6, 5.00, 140000.00), (12, 13, 100.00, 12000.00),
(13, 8, 600.00, 18000.00), (13, 9, 1500.00, 8250.00),
(14, 10, 2500.00, 4500.00), (14, 11, 3000.00, 3600.00),
(15, 14, 20.00, 10000.00), (15, 15, 1500.00, 7500.00);

INSERT INTO contenedor (numero_contenedor, tipo, peso_kg, id_declaracion) VALUES
('MSCU-1000001', 'Seco', 18000.00, 1),
('TGHU-1000002', 'Seco', 19500.00, 2),
('CMAU-1000003', 'Seco', 21000.00, 3),
('OOLU-1000004', 'Refrigerado', 17500.00, 4),
('FSCU-1000005', 'Plataforma', 22000.00, 5),
('HLCU-1000006', 'Seco', 16500.00, 6),
('SEGU-1000007', 'Refrigerado', 20000.00, 7),
('TEMU-1000008', 'Seco', 18500.00, 8),
('CAIU-1000009', 'Seco', 19000.00, 9),
('TRHU-1000010', 'Plataforma', 20500.00, 10),
('APZU-1000011', 'Refrigerado', 17000.00, 11),
('GESU-1000012', 'Seco', 21500.00, 12),
('UETU-1000013', 'Refrigerado', 18000.00, 13),
('WHLU-1000014', 'Seco', 16000.00, 14),
('CRSU-1000015', 'Seco', 15000.00, 15);

INSERT INTO inventario
(id_bodega, id_detalle, cantidad_actual, fecha_ingreso, estado) VALUES
(2, 1, 50.00, '2026-10-01', 'Retenido'),
(2, 2, 100.00, '2026-10-01', 'Retenido'),
(1, 3, 200.00, '2026-10-02', 'Liberado'),
(1, 4, 80.00, '2026-10-02', 'Liberado'),
(3, 5, 40.00, '2026-10-03', 'En inspeccion'),
(3, 6, 25.00, '2026-10-03', 'En inspeccion'),
(4, 7, 500.00, '2026-10-04', 'Retenido'),
(4, 8, 300.00, '2026-10-04', 'Retenido'),
(5, 9, 10.00, '2026-10-05', 'Liberado'),
(5, 10, 500.00, '2026-10-05', 'Liberado'),
(6, 11, 800.00, '2026-10-06', 'En inspeccion'),
(6, 12, 1000.00, '2026-10-06', 'En inspeccion'),
(7, 13, 2000.00, '2026-10-07', 'Retenido'),
(7, 14, 5000.00, '2026-10-07', 'Retenido'),
(8, 15, 1000.00, '2026-10-08', 'Liberado'),
(8, 16, 20.00, '2026-10-08', 'Liberado'),
(9, 17, 150.00, '2026-10-09', 'Retenido'),
(9, 18, 400.00, '2026-10-09', 'Retenido'),
(10, 19, 30.00, '2026-10-10', 'En inspeccion'),
(10, 20, 250.00, '2026-10-10', 'En inspeccion'),
(11, 21, 300.00, '2026-10-11', 'Liberado'),
(11, 22, 700.00, '2026-10-11', 'Liberado'),
(12, 23, 5.00, '2026-10-12', 'Retenido'),
(12, 24, 100.00, '2026-10-12', 'Retenido'),
(13, 25, 600.00, '2026-10-13', 'En inspeccion'),
(13, 26, 1500.00, '2026-10-13', 'En inspeccion'),
(14, 27, 2500.00, '2026-09-28', 'Liberado'),
(14, 28, 3000.00, '2026-09-28', 'Liberado'),
(15, 29, 20.00, '2026-09-30', 'Liberado'),
(15, 30, 1500.00, '2026-09-30', 'Liberado');

INSERT INTO movimiento_inventario
(id_inventario, tipo, fecha_movimiento, cantidad, observacion) VALUES
(1, 'Entrada', '2026-10-01 09:00:00', 50.00, 'Ingreso inicial de computadoras'),
(2, 'Entrada', '2026-10-01 09:10:00', 100.00, 'Ingreso inicial de adaptadores'),
(3, 'Entrada', '2026-10-02 08:30:00', 200.00, 'Ingreso inicial de telefonos'),
(4, 'Entrada', '2026-10-02 08:40:00', 80.00, 'Ingreso inicial de llantas'),
(5, 'Entrada', '2026-10-03 10:00:00', 40.00, 'Ingreso inicial de escritorios'),
(6, 'Entrada', '2026-10-03 10:15:00', 25.00, 'Ingreso inicial de estructuras'),
(7, 'Entrada', '2026-10-04 09:00:00', 500.00, 'Ingreso inicial de medicamentos'),
(8, 'Entrada', '2026-10-04 09:20:00', 300.00, 'Ingreso inicial de cremas'),
(9, 'Entrada', '2026-10-05 11:00:00', 10.00, 'Ingreso inicial de automoviles'),
(10, 'Entrada', '2026-10-05 11:20:00', 500.00, 'Ingreso inicial de calzado'),
(11, 'Entrada', '2026-10-06 08:45:00', 800.00, 'Ingreso inicial de pantalones'),
(12, 'Entrada', '2026-10-06 09:00:00', 1000.00, 'Ingreso inicial de arroz'),
(13, 'Entrada', '2026-10-07 07:30:00', 2000.00, 'Ingreso inicial de carne congelada'),
(14, 'Entrada', '2026-10-07 07:45:00', 5000.00, 'Ingreso inicial de cerveza'),
(15, 'Entrada', '2026-10-08 10:30:00', 1000.00, 'Ingreso inicial de juguetes'),
(16, 'Entrada', '2026-10-08 10:45:00', 20.00, 'Ingreso inicial de computadoras'),
(17, 'Entrada', '2026-10-09 09:10:00', 150.00, 'Ingreso inicial de telefonos'),
(18, 'Entrada', '2026-10-09 09:25:00', 400.00, 'Ingreso inicial de cremas'),
(19, 'Entrada', '2026-10-10 08:20:00', 30.00, 'Ingreso inicial de escritorios'),
(20, 'Entrada', '2026-10-10 08:35:00', 250.00, 'Ingreso inicial de adaptadores'),
(21, 'Entrada', '2026-10-11 09:40:00', 300.00, 'Ingreso inicial de medicamentos'),
(22, 'Entrada', '2026-10-11 09:55:00', 700.00, 'Ingreso inicial de calzado'),
(23, 'Entrada', '2026-10-12 11:10:00', 5.00, 'Ingreso inicial de automoviles'),
(24, 'Entrada', '2026-10-12 11:25:00', 100.00, 'Ingreso inicial de llantas'),
(25, 'Entrada', '2026-10-13 07:50:00', 600.00, 'Ingreso inicial de pantalones'),
(26, 'Entrada', '2026-10-13 08:05:00', 1500.00, 'Ingreso inicial de carne congelada'),
(27, 'Entrada', '2026-09-28 09:00:00', 2500.00, 'Ingreso inicial de arroz'),
(28, 'Entrada', '2026-09-28 09:15:00', 3000.00, 'Ingreso inicial de cerveza'),
(29, 'Entrada', '2026-09-30 08:30:00', 20.00, 'Ingreso inicial de estructuras'),
(30, 'Entrada', '2026-09-30 08:45:00', 1500.00, 'Ingreso inicial de juguetes');

INSERT INTO inspeccion
(id_declaracion, id_funcionario, fecha_inspeccion, resultado, observaciones) VALUES
(1, 3, '2026-10-02', 'Con observaciones', 'Falta verificar el valor declarado de los adaptadores.'),
(2, 4, '2026-10-03', 'Aprobada', 'Mercancia y documentos completos.'),
(3, 5, '2026-10-04', 'Con observaciones', 'Se solicita revisar el peso del contenedor.'),
(4, 6, '2026-10-05', 'Rechazada', 'Documentacion sanitaria incompleta.'),
(5, 8, '2026-10-06', 'Aprobada', 'Vehiculos revisados sin novedades.'),
(6, 9, '2026-10-07', 'Con observaciones', 'Cantidad de arroz pendiente de conteo final.'),
(7, 10, '2026-10-08', 'Con observaciones', 'Cadena de frio requiere verificacion.'),
(8, 11, '2026-10-09', 'Aprobada', 'Juguetes y computadoras liberados.'),
(9, 12, '2026-10-10', 'Con observaciones', 'Telefonos pendientes de clasificacion arancelaria.'),
(10, 13, '2026-10-11', 'Aprobada', 'Estructuras y adaptadores en deposito.'),
(11, 14, '2026-10-12', 'Aprobada', 'Medicamentos con permisos validos.'),
(12, 15, '2026-10-13', 'Con observaciones', 'Vehiculos pendientes de valoracion.'),
(13, 3, '2026-10-14', 'Aprobada', 'Transito autorizado hacia Panama.'),
(14, 4, '2026-09-29', 'Aprobada', 'Importacion cerrada correctamente.'),
(15, 5, '2026-10-01', 'Aprobada', 'Exportacion registrada sin observaciones.');

-- =========================================================
-- 4. CONSULTAS SQL ANALITICAS (FASE 4)
-- =========================================================

-- Consulta 1: cantidad de declaraciones de importacion registradas en octubre de 2026.
-- JOIN: permite mostrar el dato junto con los operadores que declararon.
-- GROUP BY: agrupa el resultado por mes.
SELECT
    DATE_FORMAT(d.fecha, '%Y-%m') AS periodo,
    COUNT(d.id_declaracion) AS total_declaraciones_importacion
FROM declaracion_aduanera AS d
INNER JOIN operador_comercial AS o
    ON d.id_operador = o.id_operador
WHERE d.regimen = 'Importacion'
  AND d.fecha >= '2026-10-01'
  AND d.fecha < '2026-11-01'
GROUP BY DATE_FORMAT(d.fecha, '%Y-%m')
ORDER BY periodo;

-- Consulta 2: mercancias que siguen retenidas y la bodega donde se encuentran.
SELECT
    p.descripcion AS producto,
    i.cantidad_actual,
    pr.nombre AS pais_origen,
    b.nombre AS bodega,
    d.numero AS declaracion
FROM inventario AS i
INNER JOIN bodega AS b
    ON i.id_bodega = b.id_bodega
INNER JOIN detalle_declaracion AS dd
    ON i.id_detalle = dd.id_detalle
INNER JOIN producto AS p
    ON dd.id_producto = p.id_producto
INNER JOIN declaracion_aduanera AS d
    ON dd.id_declaracion = d.id_declaracion
INNER JOIN pais AS pr
    ON d.id_pais_origen = pr.id_pais
WHERE i.estado = 'Retenido'
ORDER BY b.nombre, p.descripcion;

-- Consulta 3: pais de origen con mas contenedores recibidos en importaciones.
SELECT
    p.nombre AS pais_origen,
    COUNT(c.id_contenedor) AS total_contenedores
FROM contenedor AS c
INNER JOIN declaracion_aduanera AS d
    ON c.id_declaracion = d.id_declaracion
INNER JOIN pais AS p
    ON d.id_pais_origen = p.id_pais
WHERE d.regimen = 'Importacion'
GROUP BY p.id_pais, p.nombre
ORDER BY total_contenedores DESC, pais_origen
LIMIT 1;

-- Consulta 4: operador que ha declarado el valor total mas alto en importaciones.
SELECT
    o.razon_social AS operador,
    SUM(dd.valor_declarado) AS valor_total_declarado
FROM operador_comercial AS o
INNER JOIN declaracion_aduanera AS d
    ON o.id_operador = d.id_operador
INNER JOIN detalle_declaracion AS dd
    ON d.id_declaracion = dd.id_declaracion
WHERE d.regimen = 'Importacion'
GROUP BY o.id_operador, o.razon_social
ORDER BY valor_total_declarado DESC
LIMIT 1;

-- Consulta 5: inspecciones con observaciones y el funcionario responsable.
SELECT
    i.id_inspeccion,
    d.numero AS declaracion,
    f.nombre AS funcionario,
    i.fecha_inspeccion,
    i.observaciones
FROM inspeccion AS i
INNER JOIN declaracion_aduanera AS d
    ON i.id_declaracion = d.id_declaracion
INNER JOIN funcionario AS f
    ON i.id_funcionario = f.id_funcionario
WHERE i.resultado = 'Con observaciones'
ORDER BY i.fecha_inspeccion DESC, d.numero;

-- Consulta 6: stock del producto "Telefono inteligente de 128 GB" en cada bodega.
-- Para probar otro producto, se cambia el texto de la condicion WHERE.
SELECT
    p.descripcion AS producto,
    b.nombre AS bodega,
    SUM(i.cantidad_actual) AS stock_disponible
FROM inventario AS i
INNER JOIN bodega AS b
    ON i.id_bodega = b.id_bodega
INNER JOIN detalle_declaracion AS dd
    ON i.id_detalle = dd.id_detalle
INNER JOIN producto AS p
    ON dd.id_producto = p.id_producto
WHERE p.descripcion = 'Telefono inteligente de 128 GB'
GROUP BY p.id_producto, p.descripcion, b.id_bodega, b.nombre
ORDER BY stock_disponible DESC, b.nombre;

-- Consulta 7: valor de mercancia retenida, agrupado por pais de origen.
SELECT
    p.nombre AS pais_origen,
    SUM(dd.valor_declarado * (i.cantidad_actual / dd.cantidad)) AS valor_total_retenido
FROM inventario AS i
INNER JOIN detalle_declaracion AS dd
    ON i.id_detalle = dd.id_detalle
INNER JOIN declaracion_aduanera AS d
    ON dd.id_declaracion = d.id_declaracion
INNER JOIN pais AS p
    ON d.id_pais_origen = p.id_pais
WHERE i.estado = 'Retenido'
GROUP BY p.id_pais, p.nombre
ORDER BY valor_total_retenido DESC;

-- Consulta 8: cantidad total ingresada por bodega durante octubre de 2026.
SELECT
    b.nombre AS bodega,
    COUNT(m.id_movimiento) AS movimientos_entrada,
    SUM(m.cantidad) AS cantidad_total_ingresada
FROM movimiento_inventario AS m
INNER JOIN inventario AS i
    ON m.id_inventario = i.id_inventario
INNER JOIN bodega AS b
    ON i.id_bodega = b.id_bodega
WHERE m.tipo = 'Entrada'
  AND m.fecha_movimiento >= '2026-10-01 00:00:00'
  AND m.fecha_movimiento < '2026-11-01 00:00:00'
GROUP BY b.id_bodega, b.nombre
ORDER BY cantidad_total_ingresada DESC, b.nombre;

-- Fin del script de estructura, datos de prueba y consultas.
