#!/usr/bin/env python3

import os
import sys
import time
import datetime
import argparse

def move_old_files(target_dir, age_threshold=7):
    """Moves files older than age_threshold days into subdirectories based on creation date within a 'backup' directory."""

    backup_dir = os.path.join(target_dir, "backup")
    os.makedirs(backup_dir, exist_ok=True) #creates the backup directory if it does not exist.

    cutoff_timestamp = time.time() - (age_threshold * 24 * 60 * 60)

    for filename in os.listdir(target_dir):
        filepath = os.path.join(target_dir, filename)

        if os.path.isfile(filepath):
            try:
                file_timestamp = os.path.getmtime(filepath)
                if file_timestamp < cutoff_timestamp:
                    file_date = datetime.datetime.fromtimestamp(file_timestamp).strftime("%Y-%m-%d")
                    dest_dir = os.path.join(backup_dir, file_date) #now the date directories are inside of the backup directory.

                    os.makedirs(dest_dir, exist_ok=True)

                    dest_path = os.path.join(dest_dir, filename)

                    try:
                        os.rename(filepath, dest_path)
                        print(f"Moved {filename} to {dest_dir}")
                    except OSError as e:
                        print(f"Failed to move {filename}: {e}")

            except OSError as e:
                print(f"Error processing {filename}: {e}")

def main():
    parser = argparse.ArgumentParser(description="Move old files to date-based subdirectories within a 'backup' directory.")
    parser.add_argument("target_dir", help="The target directory to process.")
    parser.add_argument("-a", "--age", type=int, default=7, help="Age threshold in days (default: 7).")

    args = parser.parse_args()

    target_dir = args.target_dir
    age_threshold = args.age

    if not os.path.exists(target_dir):
        print(f"Error: Target directory '{target_dir}' does not exist.")
        sys.exit(1)

    if not os.path.isdir(target_dir):
        print(f"Error: '{target_dir}' is not a directory.")
        sys.exit(1)

    if not os.access(target_dir, os.W_OK):
        print(f"Error: Target directory '{target_dir}' is not writable.")
        sys.exit(1)

    move_old_files(target_dir, age_threshold)

if __name__ == "__main__":
    main()
