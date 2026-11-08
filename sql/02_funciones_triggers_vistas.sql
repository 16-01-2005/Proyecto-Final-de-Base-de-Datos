-- Precio total = suma de cada noche (tarifa especial si existe, si no la tarifa base)
CREATE OR REPLACE FUNCTION fn_calcular_precio(p_propiedad INT, p_inicio DATE, p_fin DATE)
RETURNS DECIMAL(10,2) AS $$
    SELECT COALESCE(SUM(COALESCE(
               (SELECT pe.precio_noche
                  FROM PRECIO_ESPECIAL pe
                 WHERE pe.id_propiedad = p.id_propiedad
                   AND d::date BETWEEN pe.fecha_inicio AND pe.fecha_fin),
               p.precio_base_noche)), 0)
      FROM PROPIEDAD p,
           generate_series(p_inicio, p_fin - 1, INTERVAL '1 day') AS d
     WHERE p.id_propiedad = p_propiedad;
$$ LANGUAGE SQL STABLE;

-- Reglas de negocio de una reserva (se ejecuta antes de INSERT/UPDATE)
CREATE OR REPLACE FUNCTION fn_validar_reserva() RETURNS TRIGGER AS $$
DECLARE
    v_capacidad INT;
    v_anfitrion INT;
BEGIN
    SELECT capacidad_maxima, id_anfitrion INTO v_capacidad, v_anfitrion
      FROM PROPIEDAD WHERE id_propiedad = NEW.id_propiedad;
    IF NEW.num_huespedes > v_capacidad THEN
        RAISE EXCEPTION 'La propiedad admite máximo % huéspedes', v_capacidad;
    END IF;
    IF NEW.id_huesped = v_anfitrion THEN
        RAISE EXCEPTION 'El anfitrión no puede reservar su propia propiedad';
    END IF;
    NEW.precio_total := fn_calcular_precio(NEW.id_propiedad, NEW.fecha_inicio, NEW.fecha_fin);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_reserva
BEFORE INSERT OR UPDATE ON RESERVA
FOR EACH ROW EXECUTE FUNCTION fn_validar_reserva();

-- Índices para búsquedas frecuentes
CREATE INDEX idx_propiedad_ciudad   ON PROPIEDAD (ciudad);
CREATE INDEX idx_reserva_huesped    ON RESERVA (id_huesped);

-- Vista de ingresos mensuales por anfitrión
CREATE VIEW VW_INGRESOS_ANFITRION AS
SELECT u.id_usuario AS id_anfitrion,
       u.nombre || ' ' || u.apellido AS anfitrion,
       DATE_TRUNC('month', r.fecha_inicio)::date AS mes,
       COUNT(*)            AS reservas,
       SUM(r.precio_total) AS ingresos
  FROM USUARIO u
  JOIN PROPIEDAD p ON p.id_anfitrion = u.id_usuario
  JOIN RESERVA   r ON r.id_propiedad = p.id_propiedad
 WHERE r.estado IN ('CONFIRMADA', 'COMPLETADA')
 GROUP BY u.id_usuario, u.nombre, u.apellido, DATE_TRUNC('month', r.fecha_inicio);

-- Vista de tasa de ocupación (noches reservadas del año 2026 / 365)
CREATE VIEW VW_OCUPACION_2026 AS
SELECT p.id_propiedad, p.titulo,
       COALESCE(SUM(r.fecha_fin - r.fecha_inicio), 0) AS noches_reservadas,
       ROUND(COALESCE(SUM(r.fecha_fin - r.fecha_inicio), 0) * 100.0 / 365, 2) AS ocupacion_pct
  FROM PROPIEDAD p
  LEFT JOIN RESERVA r ON r.id_propiedad = p.id_propiedad
       AND r.estado IN ('CONFIRMADA', 'COMPLETADA')
       AND r.fecha_inicio >= DATE '2026-01-01' AND r.fecha_fin <= DATE '2026-12-31'
 GROUP BY p.id_propiedad, p.titulo;
