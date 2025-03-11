#!/bin/bash

#This script MUST be ran from the folder used for your docker-compose.yml file for Immich.

SOURCE="/PATH/TO/YOUR/immich/library/" #adjust to correct Immich library
DEST_DB="vault:database" #adjust to correct bucket for database
DEST_LIB="vault:library" #adjust to correct bucket for library
SYNCDIR="/PATH/TO BACKUP DIRECTORY/backup" #preferably in your $HOME directory
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$SYNCDIR/logs/immich_backup_$TIMESTAMP.log" #Stores logs
DB_BACKUP_FILE="$SYNCDIR/database_backup/immich_db_$TIMESTAMP.sql.gz"

if [ ! -f "$LOG_FILE" ]; then
    echo "$LOG_FILE not found. Creating file."
    mkdir -p "$SYNCDIR/logs"
    touch "$LOG_FILE"
else
    echo "$LOG_FILE successfully located."
fi

if [ ! -d "$SYNCDIR/database_backup/" ]; then
    echo "Sync Directory is missing, creating now."
    mkdir -p "$SYNCDIR/database_backup/"
else
    echo "Sync directory located."
fi

echo "[$TIMESTAMP] Backup protocol initiated, standby." >> "$LOG_FILE"

echo "Database dump in progress."

sudo docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | gzip > "$DB_BACKUP_FILE"

echo "Database dump completed. Backing up."

rclone sync "$SYNCDIR/database_backup" "$DEST_DB" -v --delete-excluded --transfers 10 --fast-list >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "Database backup complete. Proceeding to library backup."
    rclone sync "$SOURCE" "$DEST_LIB" -v --delete-excluded --transfers 10 --fast-list >> "$LOG_FILE" 2>&1
else
    echo "Fatal error. Unable to backup. Check variables."  && exit
fi

if [ $EXIT_CODE -eq 0 ]; then
    echo "[$TIMESTAMP] Backup protocol has completed successfully. Data has been encrypted (if rclone is configured to do so) and stored in $DEST_DB" and "$DEST_LIB" >> "$LOG_FILE"
    echo "[$TIMESTAMP] Backup has been completed. Check log for details."
else
    echo "[$TIMESTAMP] Backup protocol has failed with exit code: $EXIT_CODE" >> "$LOG_FILE"
fi
