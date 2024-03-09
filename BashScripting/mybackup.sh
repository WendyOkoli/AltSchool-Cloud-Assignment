#!/bin/bash

timestamp=$(date +'%Y_%m_%d_%H_%M_%S')
source_dir=$1
destination_dir=$2
backup_directory=$destination_dir/backup_$timestamp.tar.gz
# echo $backup_directory


if [[ -d "$destination_dir" ]]; then
  echo "$destination_dir already exists"
else
   mkdir $destination_dir
  echo "Successfully Created: ($destination_dir)"
fi


tar -cvzf "$backup_directory" -C "$(dirname "$source_dir")" "$(basename "$source_dir")" && echo "Backup Created Succesfully: $backup_directory"