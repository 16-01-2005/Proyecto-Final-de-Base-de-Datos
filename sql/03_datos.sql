INSERT INTO USUARIO (nombre, apellido, email, telefono, tipo_usuario, fecha_registro) VALUES
('Carlos',  'Andrade',  'carlos.andrade@example.com',  '0991111111', 'ANFITRION', '2025-03-10'),
('María',   'Torres',   'maria.torres@example.com',    '0992222222', 'ANFITRION', '2025-04-02'),
('Luis',    'Pérez',    'luis.perez@example.com',      '0983333333', 'HUESPED',   '2025-06-15'),
('Ana',     'Calderón', 'ana.calderon@example.com',    '0984444444', 'HUESPED',   '2025-07-21'),
('Diego',   'Romero',   'diego.romero@example.com',    '0995555555', 'AMBOS',     '2025-08-05'),
('Sofía',   'Jaramillo','sofia.jaramillo@example.com', '0986666666', 'HUESPED',   '2025-09-30'),
('Pedro',   'Valarezo', 'pedro.valarezo@example.com',  '0997777777', 'ANFITRION', '2026-01-12'),
('Valeria', 'Ordóñez',  'valeria.ordonez@example.com', '0988888888', 'HUESPED',   '2026-02-18');

INSERT INTO SERVICIO (nombre) VALUES
('WiFi'), ('Piscina'), ('Aire acondicionado'), ('Estacionamiento'),
('Cocina equipada'), ('Mascotas permitidas');

INSERT INTO PROPIEDAD (id_anfitrion, titulo, descripcion, direccion, ciudad, latitud, longitud,
                       precio_base_noche, capacidad_maxima, habitaciones) VALUES
(1, 'Cabaña Vilcabamba',          'Cabaña rodeada de montañas',       'Vía a Yamburara km 2',
    'Vilcabamba', -4.261500, -79.222000,  65.00, 6, 3),
(1, 'Departamento Centro Loja',   'Departamento céntrico y moderno',  'Bolívar y Mercadillo',
    'Loja',       -3.993100, -79.204200,  40.00, 4, 2),
(2, 'Casa de Playa Montañita',    'Casa frente al mar con piscina',   'Av. Principal s/n',
    'Montañita',  -1.826400, -80.752500, 120.00, 8, 4),
(2, 'Suite Cuenca Histórica',     'Suite en el centro histórico',     'Calle Larga 5-24',
    'Cuenca',     -2.897400, -79.004500,  55.00, 2, 1),
(7, 'Casa Campestre Zamora',      'Casa con jardín y río cercano',    'Vía a Yacuambi km 4',
    'Zamora',     -4.069200, -78.956700,  80.00, 5, 3),
(5, 'Loft La Floresta',           'Loft artístico para viajeros',     'Calle Galavis y Toledo',
    'Quito',      -0.200000, -78.490000,  70.00, 3, 1);

INSERT INTO PROPIEDAD_SERVICIO (id_propiedad, id_servicio) VALUES
(1,1),(1,2),(1,4),(1,5),(1,6),
(2,1),(2,3),(2,5),
(3,1),(3,2),(3,3),(3,4),
(4,1),(4,3),(4,5),
(5,1),(5,2),(5,4),(5,5),(5,6),
(6,1),(6,3),(6,5);

INSERT INTO PRECIO_ESPECIAL (id_propiedad, fecha_inicio, fecha_fin, precio_noche, motivo) VALUES
(3, '2026-12-20', '2027-01-06', 180.00, 'Fiestas de fin de año'),
(3, '2027-02-13', '2027-02-17', 160.00, 'Carnaval'),
(1, '2026-12-24', '2026-12-28',  85.00, 'Navidad'),
(4, '2026-11-01', '2026-11-04',  75.00, 'Feriado de noviembre'),
(5, '2026-12-26', '2027-01-02', 110.00, 'Fin de año');

INSERT INTO RESERVA (id_propiedad, id_huesped, fecha_inicio, fecha_fin, num_huespedes,
    precio_total, estado) VALUES
(1, 3, '2026-10-10', '2026-10-13', 3, 195.00, 'COMPLETADA'),
(1, 4, '2026-11-20', '2026-11-24', 4, 260.00, 'CONFIRMADA'),
(2, 3, '2026-09-01', '2026-09-04', 2, 120.00, 'COMPLETADA'),
(3, 6, '2026-08-14', '2026-08-18', 5, 480.00, 'COMPLETADA'),
(3, 8, '2026-12-24', '2026-12-28', 6, 720.00, 'CONFIRMADA'),
(4, 4, '2026-10-02', '2026-10-05', 2, 165.00, 'COMPLETADA'),
(5, 5, '2026-10-17', '2026-10-20', 4, 240.00, 'COMPLETADA'),
(5, 6, '2026-10-18', '2026-10-21', 3, 240.00, 'CANCELADA'),
(6, 3, '2026-11-14', '2026-11-16', 2, 140.00, 'PENDIENTE'),
(2, 8, '2026-11-28', '2026-12-01', 3, 120.00, 'CONFIRMADA'),
(1, 8, '2026-08-05', '2026-08-08', 2, 195.00, 'COMPLETADA'),
(4, 6, '2026-11-10', '2026-11-13', 2, 165.00, 'CONFIRMADA');

INSERT INTO PAGO (id_reserva, monto, metodo, estado, fecha_pago) VALUES
(1, 195.00, 'TARJETA',       'PAGADO',      '2026-10-01'),
(2, 260.00, 'TRANSFERENCIA', 'PAGADO',      '2026-11-01'),
(3, 120.00, 'EFECTIVO',      'PAGADO',      '2026-08-28'),
(4, 480.00, 'TARJETA',       'PAGADO',      '2026-08-01'),
(5, 720.00, 'TARJETA',       'PAGADO',      '2026-11-02'),
(6, 165.00, 'TRANSFERENCIA', 'PAGADO',      '2026-09-25'),
(7, 240.00, 'TARJETA',       'PAGADO',      '2026-10-10'),
(8, 240.00, 'TARJETA',       'REEMBOLSADO', '2026-10-12'),
(10,120.00, 'TRANSFERENCIA', 'PAGADO',      '2026-11-03'),
(11,195.00, 'EFECTIVO',      'PAGADO',      '2026-07-30'),
(12,165.00, 'TARJETA',       'PAGADO',      '2026-11-05');

INSERT INTO RESENA (id_reserva, calificacion, comentario, fecha_creacion) VALUES
(1,  5, 'Excelente cabaña, muy tranquila y limpia.',        '2026-10-14'),
(3,  4, 'Muy buena ubicación en el centro de Loja.',        '2026-09-05'),
(4,  5, 'La casa de playa superó nuestras expectativas.',   '2026-08-19'),
(6,  3, 'Bonita suite, pero algo ruidosa por la noche.',    '2026-10-06'),
(7,  5, 'Lugar ideal para descansar en familia.',           '2026-10-21'),
(11, 4, 'Buena atención del anfitrión y vista increíble.',  '2026-08-09');
