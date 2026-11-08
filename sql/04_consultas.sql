-- Consultas de álgebra relacional traducidas a SQL (ver docs/Informe_Fin_Unidad1.docx)

-- Consulta 1: reunión natural de 4 tablas, selección, proyección, renombrado
SELECT r.id_reserva, p.titulo,
       h.nombre || ' ' || h.apellido AS huesped,
       a.nombre || ' ' || a.apellido AS anfitrion,
       r.fecha_inicio, r.fecha_fin, r.precio_total
FROM RESERVA r
JOIN PROPIEDAD p ON r.id_propiedad = p.id_propiedad
JOIN USUARIO   h ON r.id_huesped   = h.id_usuario
JOIN USUARIO   a ON p.id_anfitrion = a.id_usuario
WHERE r.estado = 'CONFIRMADA'
  AND r.fecha_inicio > DATE '2026-11-07'
ORDER BY r.fecha_inicio;

-- Consulta 2: diferencia (propiedades disponibles del 20 al 23 de nov 2026, capacidad >= 4)
SELECT p.titulo, p.ciudad, p.precio_base_noche
FROM PROPIEDAD p
WHERE p.capacidad_maxima >= 4
  AND p.id_propiedad NOT IN (
        SELECT r.id_propiedad
        FROM RESERVA r
        WHERE r.estado IN ('PENDIENTE', 'CONFIRMADA')
          AND r.fecha_inicio < DATE '2026-11-23'
          AND r.fecha_fin    > DATE '2026-11-20');

-- Consulta 3: intersección (huéspedes con ambos anfitriones)
SELECT u.id_usuario, u.nombre, u.apellido
FROM USUARIO u
WHERE u.id_usuario IN (
        SELECT r.id_huesped
        FROM RESERVA r
        JOIN PROPIEDAD p ON r.id_propiedad = p.id_propiedad
        WHERE p.id_anfitrion = 1 AND r.estado <> 'CANCELADA'
        INTERSECT
        SELECT r.id_huesped
        FROM RESERVA r
        JOIN PROPIEDAD p ON r.id_propiedad = p.id_propiedad
        WHERE p.id_anfitrion = 2 AND r.estado <> 'CANCELADA')
ORDER BY u.id_usuario;

-- Consulta 4: división (propiedades con WiFi, Piscina y Estacionamiento)
SELECT p.id_propiedad, p.titulo, p.ciudad
FROM PROPIEDAD p
WHERE NOT EXISTS (
        SELECT 1
        FROM SERVICIO s
        WHERE s.nombre IN ('WiFi', 'Piscina', 'Estacionamiento')
          AND NOT EXISTS (
                SELECT 1
                FROM PROPIEDAD_SERVICIO ps
                WHERE ps.id_propiedad = p.id_propiedad
                  AND ps.id_servicio  = s.id_servicio));

-- Consulta 5: agrupamiento y agregación (ingresos y calificación por anfitrión)
SELECT a.id_usuario,
       a.nombre || ' ' || a.apellido AS anfitrion,
       COUNT(r.id_reserva)           AS reservas_completadas,
       SUM(r.precio_total)           AS ingresos_totales,
       ROUND(AVG(rs.calificacion), 2) AS calificacion_promedio
FROM USUARIO a
JOIN PROPIEDAD p ON p.id_anfitrion = a.id_usuario
JOIN RESERVA   r ON r.id_propiedad = p.id_propiedad
JOIN RESENA   rs ON rs.id_reserva  = r.id_reserva
WHERE r.estado = 'COMPLETADA'
GROUP BY a.id_usuario, a.nombre, a.apellido
HAVING SUM(r.precio_total) > 300
ORDER BY ingresos_totales DESC;
