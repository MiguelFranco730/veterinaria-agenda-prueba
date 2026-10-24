-- Esquema de la agenda veterinaria
-- 1. Tablas independientes
CREATE TABLE responsables (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre    VARCHAR(120) NOT NULL,
  telefono  VARCHAR(30)  NOT NULL,
  correo    VARCHAR(120) UNIQUE
);

CREATE TABLE servicios (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre           VARCHAR(100) NOT NULL UNIQUE,
  duracion_minutos INT NOT NULL CHECK (duracion_minutos > 0),
  activo           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE profesionales (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre        VARCHAR(120) NOT NULL,
  especialidad  VARCHAR(80),
  activo        BOOLEAN NOT NULL DEFAULT TRUE
);

-- 2. Dependen de las anteriores
CREATE TABLE mascotas (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre         VARCHAR(80) NOT NULL,
  especie        VARCHAR(40) NOT NULL,
  raza           VARCHAR(60),
  responsable_id BIGINT NOT NULL REFERENCES responsables(id)
);

CREATE TABLE disponibilidades (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  profesional_id  BIGINT NOT NULL REFERENCES profesionales(id),
  fecha           DATE NOT NULL,
  hora_inicio     TIME NOT NULL,
  hora_fin        TIME NOT NULL,
  CHECK (hora_fin > hora_inicio)
);

-- 3. Tabla central
CREATE TABLE citas (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mascota_id      BIGINT NOT NULL REFERENCES mascotas(id),
  profesional_id  BIGINT NOT NULL REFERENCES profesionales(id),
  servicio_id     BIGINT NOT NULL REFERENCES servicios(id),
  inicio          TIMESTAMP NOT NULL,
  fin             TIMESTAMP NOT NULL,
  estado          VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA'
                  CHECK (estado IN ('PROGRAMADA','ATENDIDA','CANCELADA')),
  CHECK (fin > inicio)
);
CREATE INDEX idx_citas_agenda ON citas (profesional_id, inicio);

-- 4. Trazabilidad
CREATE TABLE historial_estado_cita (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cita_id          BIGINT NOT NULL REFERENCES citas(id),
  estado_anterior  VARCHAR(20),
  estado_nuevo     VARCHAR(20) NOT NULL,
  cambiado_en      TIMESTAMP NOT NULL DEFAULT now()
);