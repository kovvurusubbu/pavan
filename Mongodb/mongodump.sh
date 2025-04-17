#!/bin/bash

# Define variables
HOST="12345676543"
USER="team"
PASSWORD="Z3HCGrf"
PORT="55017"
AUTH_DB="product-catalog"
DB_NAME="product-catalog"
OUTPUT_DIR="/home/upsure/mongodump"
COLLECTIONS=("channel_partners_valuelists" "cp_json_req_mapper" "cp_json_res_mapper" \
"cp_product_req_json" "cp_product_res_json" "zonal_master" "zone_master" \
"zones_regions_pincodes_mapping")

# Loop through the collections and dump each one
for COLLECTION in "${COLLECTIONS[@]}"; do
    echo "Dumping collection: $COLLECTION"
    mongodump --host $HOST --port $PORT --username $USER --password $PASSWORD \
    --authenticationDatabase $AUTH_DB --db $DB_NAME --collection $COLLECTION \
    -o $OUTPUT_DIR
done

echo "Dump completed for specified collections."


chmod +x mongodump_collections.sh
./mongodump_collections.sh
