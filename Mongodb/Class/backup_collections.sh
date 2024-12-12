#!/bin/bash

HOST="35.200.208.73"
PORT="55017"
USER="inbox_qa_team"
PASSWORD="Z3HCpXIGrf"
AUTH_DB="staging-product-catalog"
DB="staging-product-catalog"
OUTPUT_DIR="/home/upsure/mongo/backup"

# List of collections to back up
collections=(
  "channel_products_application_from_dynamic"
  "channel_products_application_form_content_dynamic"
  "channel_partner_basicform_dynamic"
  "channel_partner_basicform_content_dynamic"
  "channel_products"
  "cp_product_req_json"
  "cp_json_req_mapper"
  "cp_product_res_json"
  "cp_json_res_mapper"
  "channel_partners_valuelists"
  "channel_partners"
)

# Loop through collections and back them up
for collection in "${collections[@]}"; do
  echo "Backing up collection: $collection"
  mongodump --host $HOST --port $PORT -u $USER -p "$PASSWORD" --authenticationDatabase $AUTH_DB --db $DB --collection $collection -o $OUTPUT_DIR
done

