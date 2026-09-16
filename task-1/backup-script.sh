#!/bin/bash

# Implementation of basic incremental backup script
# This script doesnt support resuming an existing backup
# Everytime this script run, it will generate a new backup folder

# Config Var
BACKUP_NAME="your-project-name"

# Global Var
WATCHED_FOLDER="$(pwd)/hpc-dir"
BACKUP_FOLDER="$(pwd)/backup/$BACKUP_NAME"
LATEST_BACKUP=""

# Full backup needed for init
full_backup() {
  timestamp=$(date -u +%Y%m%d_%H%M%S_UTC)
  target="$BACKUP_FOLDER/full-backup_$timestamp"
  mkdir -p "$target"
  cp -r "$WATCHED_FOLDER/." "$target"
  LATEST_BACKUP="$target"
}

# Directory diff checker
check_dir_diff() {
  echo "check dir diff"
}

# File diff checker
check_file_diff() {
  diff 
  echo "check file diff"
}

incremental_backup() {
  check_dir_diff
}

full_backup