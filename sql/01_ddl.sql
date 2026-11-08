CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE USUARIO (
    id_usuario     SERIAL       PRIMARY KEY,
    nombre         VARCHAR(60)  NOT NULL,
    apellido       VARCHAR(60)  NOT NULL,
    email          VARCHAR(120) NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    tipo_usuario   VARCHAR(10)  NOT NULL DEFAULT 'HUESPED'
                   CHECK (tipo_usuario IN ('ANFITRION', 'HUESPED', 'AMBOS')),
    fecha_registro DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE PROPIEDAD (
    id_propiedad      SERIAL        PRIMARY KEY,
    id_anfitrion      INT           NOT NULL REFERENCES USUARIO(id_usuario),
    titulo            VARCHAR(120)  NOT NULL,
    descripcion       TEXT,
    direccion         VARCHAR(200)  NOT NULL,
    ciudad            VARCHAR(60)   NOT NULL,
    latitud           DECIMAL(9,6),
    longitud          DECIMAL(9,6),
    precio_base_noche DECIMAL(8,2)  NOT NULL CHECK (precio_base_noche > 0),
    capacidad_maxima  INT           NOT NULL CHECK (capacidad_maxima > 0),
    habitaciones      INT           NOT NULL CHECK (habitaciones >= 1),
    activa            BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE SERVICIO (
    id_servicio SERIAL      PRIMARY KEY,
    nombre      VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE PROPIEDAD_SERVICIO (
    id_propiedad INT NOT NULL REFERENCES PROPIEDAD(id_propiedad) ON DELETE CASCADE,
    id_servicio  INT NOT NULL REFERENCES SERVICIO(id_servicio),
    PRIMARY KEY (id_propiedad, id_servicio)
);

CREATE TABLE PRECIO_ESPECIAL (
    id_precio    SERIAL        PRIMARY KEY,
    id_propiedad INT           NOT NULL REFERENCES PROPIEDAD(id_propiedad) ON DELETE CASCADE,
    fecha_inicio DATE          NOT NULL,
    fecha_fin    DATE          NOT NULL,
    precio_noche DECIMAL(8,2)  NOT NULL CHECK (precio_noche > 0),
    motivo       VARCHAR(80)   NOT NULL,
    CHECK (fecha_fin >= fecha_inicio),
    -- una propiedad no puede tener dos tarifas especiales que se crucen
    EXCLUDE USING gist (
        id_propiedad WITH =,
        daterange(fecha_inicio, fecha_fin, '[]') WITH &&
    )
);

CREATE TABLE RESERVA (
    id_reserva      SERIAL        PRIMARY KEY,
    id_propiedad    INT           NOT NULL REFERENCES PROPIEDAD(id_propiedad),
    id_huesped      INT           NOT NULL REFERENCES USUARIO(id_usuario),
    fecha_inicio    DATE          NOT NULL,
    fecha_fin       DATE          NOT NULL,
    num_huespedes   INT           NOT NULL CHECK (num_huespedes > 0),
    precio_total    DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (precio_total >= 0),
    estado          VARCHAR(12)   NOT NULL DEFAULT 'PENDIENTE'
                    CHECK (estado IN ('PENDIENTE','CONFIRMADA','CANCELADA','COMPLETADA')),
    fecha_creacion  TIMESTAMP     NOT NULL DEFAULT NOW(),
    CHECK (fecha_fin > fecha_inicio),
    -- Garantía estricta: ninguna propiedad con dos reservas activas que se solapen
    EXCLUDE USING gist (
        id_propiedad WITH =,
        daterange(fecha_inicio, fecha_fin, '[)') WITH &&
    ) WHERE (estado IN ('PENDIENTE', 'CONFIRMADA', 'COMPLETADA'))
);

CREATE TABLE PAGO (
    id_pago     SERIAL        PRIMARY KEY,
    id_reserva  INT           NOT NULL REFERENCES RESERVA(id_reserva),
    monto       DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    metodo      VARCHAR(15)   NOT NULL CHECK (metodo IN ('TARJETA','TRANSFERENCIA','EFECTIVO')),
    estado      VARCHAR(12)   NOT NULL DEFAULT 'PAGADO'
                CHECK (estado IN ('PAGADO','REEMBOLSADO')),
    fecha_pago  DATE          NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE RESENA (
    id_resena      SERIAL    PRIMARY KEY,
    id_reserva     INT       NOT NULL UNIQUE REFERENCES RESERVA(id_reserva),
    calificacion   INT       NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario     TEXT,
    fecha_creacion DATE      NOT NULL DEFAULT CURRENT_DATE
);
