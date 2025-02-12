#!/bin/bash

set -e  # Exit on error
set -x  # Debug mode

echo "$(date) - Running backup" >> /home/bitnami/backup.log

SNAPSHOT_NAME="snapshot-$(date +%Y-%m-%d_%H-%M-%S)"

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "http://localhost:9200/_snapshot/my_backup/$SNAPSHOT_NAME?wait_for_completion=true" \
  -H 'Content-Type: application/json' -d '{
    "indices": "*",
    "ignore_unavailable": true,
    "include_global_state": false
  }')

if [ "$RESPONSE" -eq 200 ]; then
  echo "$(date) - Backup successful: $SNAPSHOT_NAME" >> /home/bitnami/backup.log
else
  echo "$(date) - Backup failed with HTTP status: $RESPONSE" >> /home/bitnami/backup.log
  exit 1
fi

============================================================================
# if you  want  delete ..lost backups  use  this script

#!/bin/bash

set -e
set -x

echo "$(date) - Running backup" >> /home/bitnami/backup.log

SNAPSHOT_NAME="snapshot-$(date +%Y-%m-%d_%H-%M-%S)"

# Create a new snapshot
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "http://localhost:9200/_snapshot/my_backup/$SNAPSHOT_NAME?wait_for_completion=true" \
  -H 'Content-Type: application/json' -d '{
    "indices": "*",
    "ignore_unavailable": true,
    "include_global_state": false
  }')

if [ "$RESPONSE" -eq 200 ]; then
  echo "$(date) - Backup successful: $SNAPSHOT_NAME" >> /home/bitnami/backup.log
else
  echo "$(date) - Backup failed with HTTP status: $RESPONSE" >> /home/bitnami/backup.log
  exit 1
fi

# **Delete old snapshots (Keep only the last 28 snapshots)**
SNAPSHOTS_TO_DELETE=$(curl -s -X GET "http://localhost:9200/_snapshot/my_backup/_all" | jq -r '.snapshots | sort_by(.start_time) | .[:-28] | .[].snapshot')

for SNAPSHOT in $SNAPSHOTS_TO_DELETE; do
  echo "$(date) - Deleting old snapshot: $SNAPSHOT" >> /home/bitnami/backup.log
  curl -s -X DELETE "http://localhost:9200/_snapshot/my_backup/$SNAPSHOT" >> /home/bitnami/backup.log 2>&1
done

----------------------------------------------------------------------------
Command to List All Snapshots
curl -X GET "http://localhost:9200/_snapshot/my_backup/_all?pretty"

Example: Full Restore Process
Step 1: List Snapshots
curl -X GET "http://localhost:9200/_snapshot/my_backup/_all?pretty"

OR
Step 2: Restore a Specific Snapshot
curl -X POST "http://localhost:9200/_snapshot/my_backup/snapshot-2025-02-12_06-35-49/_restore?wait_for_completion=true&pretty"


Step 3: Verify Restore
curl -X GET "http://localhost:9200/_cat/indices?v"

====================================================================
====================================================================
IN postman  how to use ...below  all
Method: Select POST from the dropdown menu.

URL: Enter the Elasticsearch snapshot restore API endpoint:

Copy
http://localhost:9200/_snapshot/my_backup/snapshot-2025-02-12_06-35-49/_restore?wait_for_completion=true
Replace my_backup with your repository name. 
Replace snapshot-2025-02-12_06-35-49 with your snapshot name.

Headers:
Add a header for Content-Type:
Key: Content-Type
Value: application/json
Body:
Select the Raw radio button.
Choose JSON from the dropdown.
Add the following JSON payload to specify restore options:
json
Copy
{
  "indices": "*",
  "ignore_unavailable": true,
  "include_global_state": false
}
indices: "*": Restores all indices in the snapshot.
ignore_unavailable: true: Ignores missing indices.
include_global_state: false: Excludes the global cluster state.
