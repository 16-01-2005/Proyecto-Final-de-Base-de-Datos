-- ============================================================
-- Sistema de Gestión de Alquiler de Propiedades  (versión MySQL 8.0.16+)
-- Equivalente a sql/01_ddl.sql (PostgreSQL).
-- Diferencia clave: MySQL no tiene EXCLUDE USING gist, así que la
-- prohibición de reservas/tarifas solapadas se hace con TRIGGERS.
-- ============================================================

CREATE DATABASE IF NOT EXISTS alquiler_propiedades
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE alquiler_propiedades;

DROP TABLE IF EXISTS RESENA;
DROP TABLE IF EXISTS PAGO;
DROP TABLE IF EXISTS RESERVA;
DROP TABLE IF EXISTS PRECIO_ESPECIAL;
DROP TABLE IF EXISTS PROPIEDAD_SERVICIO;
DROP TABLE IF EXISTS SERVICIO;
DROP TABLE IF EXISTS PROPIEDAD;
DROP TABLE IF EXISTS USUARIO;

CREATE TABLE USUARIO (
    id_usuario     INT          AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(60)  NOT NULL,
    apellido       VARCHAR(60)  NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    tipo_usuario   VARCHAR(10)  NOT NULL DEFAULT 'HUESPED',
    fecha_registro DATE         NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT ck_usuario_tipo CHECK (tipo_usuario IN ('ANFITRION', 'HUESPED', 'AMBOS'))
) ENGINE=InnoDB;

CREATE TABLE PROPIEDAD (
    id_propiedad      INT           AUTO_INCREMENT PRIMARY KEY,
    id_anfitrion      INT           NOT NULL,
    titulo            VARCHAR(120)  NOT NULL,
    descripcion       TEXT,
    direccion         VARCHAR(200)  NOT NULL,
    ciudad            VARCHAR(60)   NOT NULL,
    latitud           DECIMAL(9,6),
    longitud          DECIMAL(9,6),
    precio_base_noche DECIMAL(8,2)  NOT NULL,
    capacidad_maxima  INT           NOT NULL,
    habitaciones      INT           NOT NULL,
    activa            BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_propiedad_anfitrion FOREIGN KEY (id_anfitrion) REFERENCES USUARIO(id_usuario),
    CONSTRAINT ck_propiedad_precio    CHECK (precio_base_noche > 0),
    CONSTRAINT ck_propiedad_capacidad CHECK (capacidad_maxima > 0),
    CONSTRAINT ck_propiedad_habit     CHECK (habitaciones >= 1)
) ENGINE=InnoDB;

CREATE TABLE SERVICIO (
    id_servicio INT         AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE PROPIEDAD_SERVICIO (
    id_propiedad INT NOT NULL,
    id_servicio  INT NOT NULL,
    PRIMARY KEY (id_propiedad, id_servicio),
    CONSTRAINT fk_ps_propiedad FOREIGN KEY (id_propiedad) REFERENCES PROPIEDAD(id_propiedad) ON DELETE CASCADE,
    CONSTRAINT fk_ps_servicio  FOREIGN KEY (id_servicio)  REFERENCES SERVICIO(id_servicio)
) ENGINE=InnoDB;

CREATE TABLE PRECIO_ESPECIAL (
    id_precio    INT           AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT           NOT NULL,
    fecha_inicio DATE          NOT NULL,
    fecha_fin    DATE          NOT NULL,
    precio_noche DECIMAL(8,2)  NOT NULL,
    motivo       VARCHAR(80)   NOT NULL,
    CONSTRAINT fk_pe_propiedad FOREIGN KEY (id_propiedad) REFERENCES PROPIEDAD(id_propiedad) ON DELETE CASCADE,
    CONSTRAINT ck_pe_precio    CHECK (precio_noche > 0),
    CONSTRAINT ck_pe_fechas    CHECK (fecha_fin >= fecha_inicio)
) ENGINE=InnoDB;

CREATE TABLE RESERVA (
    id_reserva      INT           AUTO_INCREMENT PRIMARY KEY,
    id_propiedad    INT           NOT NULL,
    id_huesped      INT           NOT NULL,
    fecha_inicio    DATE          NOT NULL,
    fecha_fin       DATE          NOT NULL,
    num_huespedes   INT           NOT NULL,
    precio_total    DECIMAL(10,2) NOT NULL DEFAULT 0,
    estado          VARCHAR(12)   NOT NULL DEFAULT 'PENDIENTE',
    fecha_creacion  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reserva_propiedad FOREIGN KEY (id_propiedad) REFERENCES PROPIEDAD(id_propiedad),
    CONSTRAINT fk_reserva_huesped   FOREIGN KEY (id_huesped)   REFERENCES USUARIO(id_usuario),
    CONSTRAINT ck_reserva_huespedes CHECK (num_huespedes > 0),
    CONSTRAINT ck_reserva_total     CHECK (precio_total >= 0),
    CONSTRAINT ck_reserva_estado    CHECK (estado IN ('PENDIENTE','CONFIRMADA','CANCELADA','COMPLETADA')),
    CONSTRAINT ck_reserva_fechas    CHECK (fecha_fin > fecha_inicio)
) ENGINE=InnoDB;

CREATE TABLE PAGO (
    id_pago     INT           AUTO_INCREMENT PRIMARY KEY,
    id_reserva  INT           NOT NULL,
    monto       DECIMAL(10,2) NOT NULL,
    metodo      VARCHAR(15)   NOT NULL,
    estado      VARCHAR(12)   NOT NULL DEFAULT 'PAGADO',
    fecha_pago  DATE          NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_pago_reserva  FOREIGN KEY (id_reserva) REFERENCES RESERVA(id_reserva),
    CONSTRAINT ck_pago_monto    CHECK (monto > 0),
    CONSTRAINT ck_pago_metodo   CHECK (metodo IN ('TARJETA','TRANSFERENCIA','EFECTIVO')),
    CONSTRAINT ck_pago_estado   CHECK (estado IN ('PAGADO','REEMBOLSADO'))
) ENGINE=InnoDB;

CREATE TABLE RESENA (
    id_resena      INT   AUTO_INCREMENT PRIMARY KEY,
    id_reserva     INT   NOT NULL UNIQUE,
    calificacion   INT   NOT NULL,
    comentario     TEXT,
    fecha_creacion DATE  NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_resena_reserva FOREIGN KEY (id_reserva) REFERENCES RESERVA(id_reserva),
    CONSTRAINT ck_resena_calif   CHECK (calificacion BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- ============================================================
-- TRIGGERS: reemplazan los EXCLUDE USING gist de PostgreSQL
-- ============================================================
DELIMITER $$

-- Una propiedad no puede tener dos reservas activas que se solapen
-- (rango [inicio, fin): la noche de salida queda libre para otro huésped)
CREATE TRIGGER trg_reserva_solape_ins BEFORE INSERT ON RESERVA
FOR EACH ROW
BEGIN
    IF NEW.estado IN ('PENDIENTE','CONFIRMADA','COMPLETADA') AND EXISTS (
        SELECT 1 FROM RESERVA r
        WHERE r.id_propiedad = NEW.id_propiedad
          AND r.estado IN ('PENDIENTE','CONFIRMADA','COMPLETADA')
          AND r.fecha_inicio < NEW.fecha_fin
          AND r.fecha_fin    > NEW.fecha_inicio
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La propiedad ya tiene una reserva activa que se solapa con esas fechas';
    END IF;
END$$

CREATE TRIGGER trg_reserva_solape_upd BEFORE UPDATE ON RESERVA
FOR EACH ROW
BEGIN
    IF NEW.estado IN ('PENDIENTE','CONFIRMADA','COMPLETADA') AND EXISTS (
        SELECT 1 FROM RESERVA r
        WHERE r.id_propiedad = NEW.id_propiedad
          AND r.id_reserva  <> NEW.id_reserva
          AND r.estado IN ('PENDIENTE','CONFIRMADA','COMPLETADA')
          AND r.fecha_inicio < NEW.fecha_fin
          AND r.fecha_fin    > NEW.fecha_inicio
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La propiedad ya tiene una reserva activa que se solapa con esas fechas';
    END IF;
END$$

-- Una propiedad no puede tener dos tarifas especiales que se crucen
-- (rango cerrado [inicio, fin])
CREATE TRIGGER trg_precio_solape_ins BEFORE INSERT ON PRECIO_ESPECIAL
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM PRECIO_ESPECIAL p
        WHERE p.id_propiedad = NEW.id_propiedad
          AND p.fecha_inicio <= NEW.fecha_fin
          AND p.fecha_fin    >= NEW.fecha_inicio
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La propiedad ya tiene una tarifa especial que se cruza con esas fechas';
    END IF;
END$$

CREATE TRIGGER trg_precio_solape_upd BEFORE UPDATE ON PRECIO_ESPECIAL
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM PRECIO_ESPECIAL p
        WHERE p.id_propiedad = NEW.id_propiedad
          AND p.id_precio   <> NEW.id_precio
          AND p.fecha_inicio <= NEW.fecha_fin
          AND p.fecha_fin    >= NEW.fecha_inicio
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La propiedad ya tiene una tarifa especial que se cruza con esas fechas';
    END IF;
END$$

DELIMITER ;
