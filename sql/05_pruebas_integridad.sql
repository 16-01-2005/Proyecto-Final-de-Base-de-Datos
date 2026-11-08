-- Cada prueba indica el resultado esperado.

-- 1) Debe FALLAR: se solapa con la reserva 2 (propiedad 1, 20-24 nov 2026)
INSERT INTO RESERVA (id_propiedad, id_huesped, fecha_inicio, fecha_fin, num_huespedes)
VALUES (1, 3, '2026-11-22', '2026-11-26', 2);
-- ERROR: conflicting key value violates exclusion constraint "reserva_id_propiedad_daterange_excl"

-- 2) Debe FUNCIONAR: solo coincide con una reserva CANCELADA; precio_total = 160.00
INSERT INTO RESERVA (id_propiedad, id_huesped, fecha_inicio, fecha_fin, num_huespedes)
VALUES (5, 3, '2026-10-20', '2026-10-22', 2) RETURNING precio_total;

-- 3) Debe FALLAR: supera la capacidad (máximo 2)
INSERT INTO RESERVA (id_propiedad, id_huesped, fecha_inicio, fecha_fin, num_huespedes)
VALUES (4, 3, '2027-03-01', '2027-03-03', 5);
-- ERROR: La propiedad admite máximo 2 huéspedes

-- 4) Debe FALLAR: el anfitrión (usuario 1) reserva su propia propiedad
INSERT INTO RESERVA (id_propiedad, id_huesped, fecha_inicio, fecha_fin, num_huespedes)
VALUES (1, 1, '2027-04-01', '2027-04-03', 2);
-- ERROR: El anfitrión no puede reservar su propia propiedad

-- Reportes
SELECT * FROM VW_INGRESOS_ANFITRION ORDER BY id_anfitrion, mes;
SELECT * FROM VW_OCUPACION_2026 ORDER BY id_propiedad;
