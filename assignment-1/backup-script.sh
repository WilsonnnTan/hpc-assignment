#!/bin/bash
#
# Implementation of basic full and differential backup script
# This script doesnt support resuming an existing backup
# Everytime this script run, it will generate a new backup folder
# This script must be executed on dir that had $WATCHED_FOLDER

# Global and Config Vars
WATCHED_FOLDER="$(pwd)/hpc-dir"
BACKUP_NAME="your-project-name"
BACKUP_FOLDER="$(pwd)/backup/$BACKUP_NAME"
BACKUP_INTERVAL=1  # minute
FULL_BACKUP_FOLDER=""

if [[ ! -d "$WATCHED_FOLDER" ]]; then
  echo "Missing folder: WATCHED FOLDER must exist"
  exit 1
fi

if [[ -d "$BACKUP_FOLDER" ]] then
  echo "Removing existing BACKUP_FOLDER to avoid dup/corrupted backup"
  rm -r "$BACKUP_FOLDER"
fi

# helper
get_timestamp() {
  timestamp=$(date -u +%Y-%m-%d_%H-%M-%S_UTC)
  echo "$timestamp"
}

full_backup() {
  echo "Running initial full backup!"
  target="$BACKUP_FOLDER/full-backup_$(get_timestamp)"

  mkdir -p "$target"
  cp -r "$WATCHED_FOLDER/." "$target"
  
  FULL_BACKUP_FOLDER="$target"
}

diff_checker() {
  # Take 2 dir path and compare both of em with diff
  local folder1=$1
  local folder2=$2
  local target_backup_folder=$3

  diff_output=$(diff -rq "$folder1" "$folder2")

  # diff output parser
  modified_pattern="^.* and '?${folder2}/(.*)'? differ"
  new_pattern="^Only in '?${folder2}(/.*)?'?: (.*)"
  deleted_pattern="^Only in '?${folder1}(/.*)?'?: (.*)"

  while read -r line; do
    if [[ "$line" =~ $modified_pattern ]]; then
      # file's content diff detected
      # example diff's output: "Files '$(pwd)/sub-dir/file.txt' and 'a-dir/sub-dir/file.txt' differ" or
      #                        "Files '$(pwd)/file.txt' and 'a-dir/file.txt' differ"
      # it is guaranteed to get "sub-dir/file-name" or "/file-name" on the parsing
      file_path_and_name="${BASH_REMATCH[1]}"
      file_path=$(dirname "$file_path_and_name")
      file_name=$(basename "$file_path_and_name")

      target_path="$target_backup_folder/$file_path"
      mkdir -p "$target_path"
      cp "$WATCHED_FOLDER/$file_path/$file_name" "$target_path"

    elif [[ "$line" =~ $new_pattern ]]; then
      # new file detected
      # example diff's output: "Only in '$(pwd)/sub-dir': file.txt" or "Only in '$(pwd)': file.txt"
      # it is not guaranteed to get "sub-dir" on the parsing (edge cases for root file)
      file_path="${BASH_REMATCH[1]}"
      file_name="${BASH_REMATCH[2]}"
      
      target_path="$target_backup_folder/$file_path"
      mkdir -p "$target_path"
      echo "DEBUG: matched new branch for line: $line" >&2
      cp "$WATCHED_FOLDER/$file_path/$file_name" "$target_path"

    elif [[ "$line" =~ $deleted_pattern ]]; then
      # deleted file detected
      # example diff's output: "Only in '$(pwd)/sub-dir': file.txt" or "Only in '$(pwd)': file.txt"
      # it is not guaranteed to get "sub-dir" on the parsing (edge cases for root file)
      file_path="${BASH_REMATCH[1]}"
      file_name="${BASH_REMATCH[2]}"

      echo "DEBUG: matched deleted branch for line: $line" >&2
      echo "$file_path/$file_name" >> "$target_backup_folder/.deleted.info"
    fi
  done <<< "$diff_output"
}

differential_backup() {
  timestamp=$(get_timestamp)
  echo "Run differential backup on $timestamp"
  
  # create diff backup folder
  target_backup_folder="$BACKUP_FOLDER/differential_backup_$timestamp"
  mkdir -p "$target_backup_folder"

  diff_checker "$FULL_BACKUP_FOLDER" "$WATCHED_FOLDER" "$target_backup_folder"
}

main() {
  # TODO: add args handler and overwrite config var
  echo "BACKUP INTERVAL: $BACKUP_INTERVAL minute"

  # Full backup for init
  full_backup
  
  # Diff backup periodically
  while true; do
    sleep $((BACKUP_INTERVAL * 60))

    differential_backup
  done
}

main