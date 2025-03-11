# Immich Backup Script

This bash script automates the backup of your Immich instance, including the database and library files.

## Prerequisites

* **Immich Setup:** You must have a running Immich instance using `docker-compose`.
* **rclone:** `rclone` must be installed and configured to access your remote backup destinations (e.g., cloud storage).
* **Bash:** This script is designed for bash, and has been tested on Ubuntu Server 24.04.2 LTS.

## Configuration

Before running the script, you need to configure the following variables:

* `SOURCE`: Path to your Immich library directory.
* `DEST_DB`: `rclone` destination for the database backup. (e.g., `vault:database`)
* `DEST_LIB`: `rclone` destination for the library backup. (e.g., `vault:library`)
* `SYNCDIR`: Path to your local backup directory. (e.g., `$HOME/immich_backup`)

**Important:** The script **must** be run from the directory containing your `docker-compose.yml` file for Immich.

## Usage

1.  **Clone or download** this script.
2.  **Edit** the script and update the configuration variables to match your environment.
3.  **Make the script executable:** `chmod +x your_script_name.sh`
4.  **Run the script:** `./your_script_name.sh`

## Script Functionality

* Creates a timestamped log file in `$SYNCDIR/logs/`.
* Creates a timestamped database backup file in `$SYNCDIR/database_backup/`.
* Dumps the Immich PostgreSQL database using `docker exec` and `pg_dumpall`, then compresses it with `gzip`.
* Uses `rclone sync` to upload the database backup to `$DEST_DB`.
* Uses `rclone sync` to upload the Immich library to `$DEST_LIB`.
* Logs all actions and errors to the log file.
* Provides status messages to the console.

## Log Files

The script generates log files in the `$SYNCDIR/logs/` directory, named `immich_backup_YYYY-MM-DD_HH-MM-SS.log`. These logs contain detailed information about the backup process.

## Backup Destinations

The script uses `rclone` to synchronize backups to remote destinations. Ensure that your `rclone` configuration is correct and that the specified destinations (`DEST_DB` and `DEST_LIB`) are accessible.

## Error Handling

The script includes basic error handling to check for successful database dumps and `rclone` operations. If an error occurs, the script will log the error and exit.

## Example Configuration

```bash
#!/bin/bash

SOURCE="/mnt/immich/library/"
DEST_DB="my_cloud_storage:immich_db_backups"
DEST_LIB="my_cloud_storage:immich_library_backups"
SYNCDIR="$HOME/immich_backups"
```

