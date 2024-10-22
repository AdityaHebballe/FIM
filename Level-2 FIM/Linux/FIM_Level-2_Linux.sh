#!/bin/bash

# Global variable for the log file name
filename="baseline.log"

log_event() {
    local message="$1"
    local path_to_monitor="$2"
    local log_filepath="$path_to_monitor/$filename"  # Log file in the monitored directory

    # Check if the log file exists and create if not
    if [ ! -f "$log_filepath" ]; then
        touch "$log_filepath"
    fi

    # Set file size limit in MB
    local file_size_limit=5
    # Check if the log file exceeds the limit
    if [ $(stat -c%s "$log_filepath") -gt $((file_size_limit * 1024 * 1024)) ]; then
        mv "$log_filepath" "$log_filepath.$(date +%Y%m%d%H%M%S)"  # Rename the old log file
    fi

    # Append the log entry with timestamp
    echo "$(date): $message" >> "$log_filepath"
}

print_colored() {
    local message="$1"
    local color="$2"
    case $color in
        green) echo -e "\033[92m$message\033[0m" ;;  
        red) echo -e "\033[91m$message\033[0m" ;;    
        yellow) echo -e "\033[93m$message\033[0m" ;;
        cyan) echo -e "\033[96m$message\033[0m" ;; 
    esac
}

main() {
    local path_to_monitor="$1"
    print_colored "Monitoring changes in: $path_to_monitor" "cyan"

    # Use inotify to read events from the monitored directory
    inotifywait -q -m -r -e modify,create,delete,moved_to,moved_from --exclude "$filename" --format '%e %f' "$path_to_monitor" | while read event; do
        event_type=$(echo $event | awk '{print $1}')
        event_name=$(echo $event | awk '{print $2}')

        case $event_type in
            MODIFY) 
                log_event "Modified: $event_name" "$path_to_monitor"
                print_colored "Modified: $event_name" "yellow"
                ;;
            CREATE) 
                log_event "Created: $event_name" "$path_to_monitor"
                print_colored "Created: $event_name" "green"
                ;;
            DELETE) 
                log_event "Deleted: $event_name" "$path_to_monitor"
                print_colored "Deleted: $event_name" "red"
                ;;
            MOVED_TO|MOVED_FROM)
                log_event "Moved: $event_name" "$path_to_monitor"
                print_colored "Moved: $event_name" "yellow"
                ;;
        esac
    done
}

read -p "Enter the path to monitor (e.g. /home/user/Documents): " path_to_monitor
if [ -d "$path_to_monitor" ]; then
    main "$path_to_monitor"
else
    print_colored "Invalid directory path." "red"
fi
