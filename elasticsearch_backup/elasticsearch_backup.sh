This script:
✅ Takes snapshots every 6 hours (4 per day)
✅ Keeps only the last 28 snapshots (7 days worth)
✅ Deletes the first snapshot of the previous week on the 8th day

#!/bin/bash

# Elasticsearch Snapshot Repository Name
REPO_NAME="my_backup"
SNAPSHOT_PREFIX="snapshot"
SNAPSHOT_NAME="${SNAPSHOT_PREFIX}-$(date +\%Y-\%m-\%d_\%H-\%M-\%S)"

# Create a new snapshot
curl -X PUT "localhost:9200/_snapshot/$REPO_NAME/$SNAPSHOT_NAME?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "*",
  "ignore_unavailable": true,
  "include_global_state": false
}'

echo "Backup taken: $SNAPSHOT_NAME"

# Get a list of all snapshots sorted by date
SNAPSHOTS=$(curl -s -X GET "localhost:9200/_snapshot/$REPO_NAME/_all?pretty" | jq -r '.snapshots[].snapshot' | sort)

# Count total snapshots
TOTAL_SNAPSHOTS=$(echo "$SNAPSHOTS" | wc -l)

# Keep only the latest 28 snapshots
if [ "$TOTAL_SNAPSHOTS" -gt 28 ]; then
    DELETE_COUNT=$((TOTAL_SNAPSHOTS - 28))
    OLD_SNAPSHOTS=$(echo "$SNAPSHOTS" | head -n $DELETE_COUNT)

    for SNAPSHOT in $OLD_SNAPSHOTS; do
        echo "Deleting old snapshot: $SNAPSHOT"
        curl -X DELETE "localhost:9200/_snapshot/$REPO_NAME/$SNAPSHOT?pretty"
    done
fi

# Remove the first snapshot of the previous week on the 8th day
if [ "$(date +%u)" -eq 1 ]; then  # Runs on Monday (1st day of the week)
    PREVIOUS_WEEK_SNAPSHOT=$(echo "$SNAPSHOTS" | head -n 1)
    echo "Deleting first snapshot of the previous week: $PREVIOUS_WEEK_SNAPSHOT"
    curl -X DELETE "localhost:9200/_snapshot/$REPO_NAME/$PREVIOUS_WEEK_SNAPSHOT?pretty"
fi

echo "Old snapshots cleanup completed."



Schedule It in Cronjob
crontab -e

Add this line to run every 6 hours (4 times a day):
0 2,8,14,20 * * * /home/bitnami/elasticsearch_backup.sh >> /home/bitnami/backup.log 2>&1

This will:
Run 4 times per day
Keep only 28 snapshots (7 days)
Delete the first snapshot of the previous week every Monday

Verify the Setup
bash /home/bitnami/elasticsearch_backup.sh

Check logs:
cat /home/bitnami/backup.log

List snapshots:
curl -X GET "localhost:9200/_snapshot/my_backup/_all?pretty"

🔹 Summary
✅ Backups taken 4 times per day
✅ Only last 28 snapshots kept
✅ Every Monday, the first snapshot from the previous week is deleted


