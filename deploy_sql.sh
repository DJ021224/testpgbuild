#!/bin/bash
set -e
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ]; then
  echo "Missing DB_HOST/DB_USER/DB_PASS"
  exit 1
fi

for f in procedures/*; do
  if [ -f "$f" ]; then
    echo "Applying $f"
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d chinook -f "$f"
  fi
done
