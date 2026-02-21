cd /root
wget https://downloads.datastax.com/dsbulk/dsbulk-1.11.0.tar.gz
tar -xvzf dsbulk-1.11.0.tar.gz
mv dsbulk-1.11.0 dsbulk

----------------------------------
in side vm

touch import-policies.sh
chmod +x  import-policies.sh
./import-policies.sh
-----------------------------
#!/bin/bash
set -e

DSBULK="/root/dsbulk/bin/dsbulk"
HOST="127.0.0.1"
KEYSPACE="policies"
DIR="/root/cs"

echo "🚀 Starting full import into Cassandra ($HOST)..."

# Check dsbulk exists
if [ ! -x "$DSBULK" ]; then
  echo "❌ dsbulk not found or not executable at $DSBULK"
  exit 1
fi

# Check directory exists
if [ ! -d "$DIR" ]; then
  echo "❌ CSV directory not found: $DIR"
  exit 1
fi

echo "🗑 Removing old data (TRUNCATE tables)..."

cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.\"config\";"
cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.messages;"
cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.metadata;"
cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.offsetstore;"
cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.policycreated;"
cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.policystatus;"
cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.snapshots;"

echo "✅ Old data removed successfully."

echo "📥 Importing fresh CSV data..."

"$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t '"config"' -url "$DIR/policies_config.csv"
"$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t messages -url "$DIR/policies_messages.csv"
"$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t metadata -url "$DIR/policies_metadata.csv"
"$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t offsetstore -url "$DIR/policies_offsetstore.csv"
"$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t policycreated -url "$DIR/policies_policycreated.csv"
"$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t policystatus -url "$DIR/policies_policystatus.csv"
"$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t snapshots -url "$DIR/policies_snapshots.csv"

echo "🎉 All POLICIES CSV files re-imported SUCCESSFULLY!"


=================================================================================================
nano import-menquiries.sh
#!/bin/bash
set -e

DSBULK="/root/dsbulk/bin/dsbulk"
HOST="127.0.0.1"
KEYSPACE="menquiries"
DIR="/root/cs"

SUCCESS=0
FAILED=0

echo "🚀 Starting SAFE import for KEYSPACE: $KEYSPACE"
echo "------------------------------------------------"

run_truncate() {
  TABLE=$1
  echo "🗑 Truncating $TABLE ..."
  cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.$TABLE;" \
    && echo "   ✅ Done" \
    || echo "   ⚠ Failed (continuing)"
}

run_load() {
  TABLE=$1
  FILE=$2

  echo "📥 Loading $TABLE ..."

  "$DSBULK" load -h "$HOST" -k "$KEYSPACE" -t "$TABLE" \
    -url "$FILE" \
    --connector.csv.maxCharsPerColumn=500000 \
    --connector.csv.maxColumns=4096 \
    --executor.maxInFlight=10000 \
    --batch.mode=PARTITION_KEY \
    --batch.size=50

  if [ $? -eq 0 ]; then
    echo "   ✅ Success"
    SUCCESS=$((SUCCESS+1))
  else
    echo "   ❌ Failed (continuing)"
    FAILED=$((FAILED+1))
  fi
}

echo "🗑 Removing old data..."

TABLES=(
  '"config"'
  messages
  metadata
  offsetstore
  snapshots
  travel_enquiry
  vehicle_enquiry
)

for T in "${TABLES[@]}"; do
  run_truncate "$T"
done

echo "------------------------------------------------"
echo "📥 Starting Data Load..."

run_load '"config"' "$DIR/menquiries_config.csv"
run_load messages "$DIR/menquiries_messages.csv"
run_load metadata "$DIR/menquiries_metadata.csv"
run_load offsetstore "$DIR/menquiries_offsetstore.csv"
run_load snapshots "$DIR/menquiries_snapshots.csv"
run_load travel_enquiry "$DIR/menquiries_travel_enquiry.csv"
run_load vehicle_enquiry "$DIR/menquiries_vehicle_enquiry.csv"

echo "------------------------------------------------"
echo "🎉 IMPORT FINISHED"
echo "   ✅ Successful tables: $SUCCESS"
echo "   ❌ Failed tables: $FAILED"
echo "------------------------------------------------"


====================================================================================================
nano import-morders.sh

#!/bin/bash

DSBULK="/root/dsbulk/bin/dsbulk"
HOST="127.0.0.1"
KEYSPACE="morders"
DIR="/root/cs"

echo "🚀 Starting STABLE import for KEYSPACE: $KEYSPACE"
echo "------------------------------------------------"

run_truncate() {
  TABLE=$1
  echo "🗑 Truncating $TABLE ..."
  cqlsh "$HOST" -e "TRUNCATE $KEYSPACE.$TABLE;" >/dev/null 2>&1
}

run_load() {
  TABLE=$1
  FILE=$2

  if [ ! -f "$FILE" ]; then
    echo "⚠ File not found: $FILE"
    return
  fi

  echo "📥 Loading $TABLE ..."

  "$DSBULK" load \
    -h "$HOST" \
    -k "$KEYSPACE" \
    -t "$TABLE" \
    -url "$FILE" \
    --connector.csv.maxCharsPerColumn=2000000 \
    --connector.csv.maxColumns=4096 \
    --executor.maxInFlight=5000 \
    --executor.maxPerSecond=0 \
    --batch.mode=PARTITION_KEY \
    --batch.size=10 \
    --driver.basic.request.timeout=5m \
    --driver.advanced.connection.pool.local.size=8 \
    --log.verbosity=normal

  if [ $? -eq 0 ]; then
    echo "✅ SUCCESS TABLE: $TABLE"
  else
    echo "❌ FAILED TABLE: $TABLE"
  fi
}

echo "🗑 Cleaning old data..."

TABLES=(
  '"config"'
  messages
  metadata
  offsetstore
  ordersbystatus
  orderscreated
  ordersstatus
  snapshots
  travelordersbystatus
  travelorderscreated
  travelordersstatus
  vehicleordersbystatus
  vehicleorderscreated
  vehicleordersstatus
)

for T in "${TABLES[@]}"; do
  run_truncate "$T"
done

echo "------------------------------------------------"
echo "📥 Starting Data Load..."

run_load '"config"' "$DIR/morders_config.csv"
run_load messages "$DIR/morders_messages.csv"
run_load metadata "$DIR/morders_metadata.csv"
run_load offsetstore "$DIR/morders_offsetstore.csv"
run_load ordersbystatus "$DIR/morders_ordersbystatus.csv"
run_load orderscreated "$DIR/morders_orderscreated.csv"
run_load ordersstatus "$DIR/morders_ordersstatus.csv"
run_load snapshots "$DIR/morders_snapshots.csv"
run_load travelordersbystatus "$DIR/morders_travelordersbystatus.csv"
run_load travelorderscreated "$DIR/morders_travelorderscreated.csv"
run_load travelordersstatus "$DIR/morders_travelordersstatus.csv"
run_load vehicleordersbystatus "$DIR/morders_vehicleordersbystatus.csv"
run_load vehicleorderscreated "$DIR/morders_vehicleorderscreated.csv"
run_load vehicleordersstatus "$DIR/morders_vehicleordersstatus.csv"

echo "------------------------------------------------"
echo "🎉 IMPORT COMPLETED"
echo "------------------------------------------------"
