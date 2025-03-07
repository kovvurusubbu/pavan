Backup_bash_script_for_postgres:
---------------------------------

#!/bin/bash
BACKUP_PATH="/home/subbu/pg/backup"
FILENAME="postgres_campaign_$(date +%Y%m%d).dump"
PGPASSWORD='xTtUQ2uytbIC' pg_dump -h 0.0.0.0.0 \
    -U subbuar_uat -d mydatabase -F c -b -v -f $BACKUP_PATH/$FILENAME
echo "Backup saved to $BACKUP_PATH/$FILENAME"




------------------------------------------------------------

restore.sh
----------

#!/bin/bash

BACKUP_FILE="/home/subbu/pg/backup/postgres_campaign_$(date +%Y%m%d).dump"
PGPASSWORD='admin' pg_restore -h 172.29.0.2 -U admin -d mydatabase -v $BACKUP_FILE

echo "Database restored successfully!"


==================================================================================================================================/
