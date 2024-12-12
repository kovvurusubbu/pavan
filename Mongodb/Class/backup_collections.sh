#!/bin/bash

HOST="IP"
PORT="55017"
USER="_team"
PASSWORD="pXIGrf"
AUTH_DB="stERTYcatalog"
DB="stERTYcatalog"
OUTPUT_DIR="/home/SUBBU/mongo/backup"

# List of collections to back up
collections=(
  "_application_from_dynamic"
  "_form_content_dynamic"
  "channel__basicform_"
  "products"
  "req_json"
  "_req_mapper"
  "cp_product"
  "cp_json_"
  "channuelists"
  "rtners"
)

# Loop through collections and back them up
for collection in "${collections[@]}"; do
  echo "Backing up collection: $collection"
  mongodump --host $HOST --port $PORT -u $USER -p "$PASSWORD" --authenticationDatabase $AUTH_DB --db $DB --collection $collection -o $OUTPUT_DIR
done

