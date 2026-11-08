#!/usr/bin/env bash
# Uso: ./scripts/setup.sh [nombre_bd]   (requiere psql y permisos para crear BD y extensiones)
set -e
DB=${1:-alquiler_db}
createdb "$DB"
for f in sql/01_ddl.sql sql/02_funciones_triggers_vistas.sql sql/03_datos.sql; do
  psql -v ON_ERROR_STOP=1 -d "$DB" -f "$f"
done
echo "Base de datos '$DB' lista. Prueba: psql -d $DB -f sql/04_consultas.sql"
