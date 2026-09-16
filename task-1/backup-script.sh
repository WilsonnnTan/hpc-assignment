#!/bin/bash

# Global Var
WATCHED_FOLDER="$(pwd)/hpc-dir"
BACKUP_FOLDER="$(pwd)/backup"

# Config Var
BACKUP_NAME="your-project-name"

# Full backup needed for init
full_backup() {
  timestamp=$(date -u +%Y%m%d_%H%M%S_UTC)
  target="$BACKUP_FOLDER/$BACKUP_NAME/full-backup_$timestamp"
  mkdir -p "$target"
  cp -r "$WATCHED_FOLDER/." "$target"
}

# Diff Checker
check_dir_diff() {
  echo "check dir diff"
}

check_file_diff() {
  echo "check file diff"
}

incremental_backup() {
  check_dir_diff
}

full_backup