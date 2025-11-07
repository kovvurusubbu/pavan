#!/bin/bash

# Define variables
HOST="mg.testing.com"
USER="wertreqrwte"
PASSWORD="ewrereer"
PORT="55017"
AUTH_DB="-product-cata"
DB_NAME="-product-cata"
OUTPUT_DIR="/home/devops/mongo"
COLLECTIONS=("city_codes_master hello_serct testing_tef")

# Loop through the collections and dump each one
for COLLECTION in "${COLLECTIONS[@]}"; do
    echo "Dumping collection: $COLLECTION"
    mongodump --host $HOST --port $PORT --username $USER --password $PASSWORD \
    --authenticationDatabase $AUTH_DB --db $DB_NAME --collection $COLLECTION \
    -o $OUTPUT_DIR
done

echo "Dump completed for specified collections."
