#!/bin/bash

# Function to calculate the hash of a file
get_file_hash() {
    local filepath="$1"
    sha512sum "$filepath" | awk '{print $1}'
}

# Function to erase the existing baseline file if it exists
erase_baseline_if_exists() {
    local baseline_path="$1"
    if [ -f "$baseline_path" ]; then
        rm "$baseline_path"
    fi
}

baseline_path="baseline.txt"

echo ""
echo "What would you like to do?"
echo "A) Collect new Baseline?"
echo "B) Begin monitoring files with saved Baseline?"

read -rp "Please enter 'A' or 'B': " response
echo ""

if [[ "$response" =~ ^[Aa]$ ]]; then
    # Delete existing baseline.txt if it exists
    erase_baseline_if_exists "$baseline_path"

    # Collect all files in the target folder
    for filepath in ./Files/*; do
        if [ -f "$filepath" ]; then
            file_hash=$(get_file_hash "$filepath")
            echo "$filepath|$file_hash" >> "$baseline_path"
        fi
    done

elif [[ "$response" =~ ^[Bb]$ ]]; then
    # Load file|hash pairs from baseline.txt into an associative array
    declare -A file_hash_dictionary
    while IFS='|' read -r file hash; do
        file_hash_dictionary["$file"]="$hash"
    done < "$baseline_path"

    # Initialize arrays to track reported files
    declare -A reported_created_files
    declare -A reported_modified_files
    declare -A reported_deleted_files

    echo "Read existing baseline.txt, start monitoring files."

    while true; do
        sleep 1

        # Check for new and modified files
        for filepath in ./Files/*; do
            if [ -f "$filepath" ]; then
                file_hash=$(get_file_hash "$filepath")

                # Check for new files
                if [[ -z "${file_hash_dictionary["$filepath"]}" ]]; then
                    if [[ -z "${reported_created_files["$filepath"]}" ]]; then
                        echo "File $filepath has been created."
                        reported_created_files["$filepath"]=1
                    fi
                else
                    # Check for modified files
                    if [[ "${file_hash_dictionary["$filepath"]}" != "$file_hash" ]]; then
                        if [[ -z "${reported_modified_files["$filepath"]}" ]]; then
                            echo "File $filepath has been modified!!"
                            reported_modified_files["$filepath"]=1
                        fi
                    fi
                fi
            fi
        done

        # Check for deleted files
        for key in "${!file_hash_dictionary[@]}"; do
            if [ ! -f "$key" ]; then
                if [[ -z "${reported_deleted_files["$key"]}" ]]; then
                    echo "File $key has been deleted."
                    reported_deleted_files["$key"]=1 
                fi
            fi
        done
    done

else
    echo "Invalid input. Please enter 'A' or 'B'"
fi
