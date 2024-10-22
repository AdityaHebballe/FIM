import os
import time
from inotify_simple import INotify, flags

def log_event(message):
    filename = "baseline.log"  # Replace with your desired filename
    # Check if the log file exists and create if not
    if not os.path.exists(filename):
        open(filename, 'a').close()

    # Set file size limit in MB
    file_size_limit = 5 
    # Check if the log file exceeds the limit
    if os.path.getsize(filename) > file_size_limit * (1024 * 1024):
        os.rename(filename, f"{filename}.{time.strftime('%Y%m%d%H%M%S')}")  # Rename the old log file

    # Append the log entry with timestamp
    with open(filename, "a") as log_file:
        log_file.write(f"{time.ctime()}: {message}\n")

def print_colored(message, color):
    colors = {
        'green': "\033[92m",  # Green
        'red': "\033[91m",    # Red
        'yellow': "\033[93m", # Yellow
        'cyan': "\033[96m",   # Cyan
        'reset': "\033[0m",   # Reset
    }
    print(f"{colors[color]}{message}{colors['reset']}")

def main(path_to_monitor):
    inotify = INotify()
    watch_flags = flags.MODIFY | flags.CREATE | flags.DELETE | flags.MOVE
    wd = inotify.add_watch(path_to_monitor, watch_flags)

    print_colored(f"Monitoring changes in: {path_to_monitor}", 'cyan')
    try:
        while True:
            for event in inotify.read():
                for flag in flags.from_mask(event.mask):
                    if flag == flags.MODIFY:
                        message = f"Modified: {event.name}"
                        log_event(message)
                        print_colored(message, 'yellow')
                    elif flag == flags.CREATE:
                        message = f"Created: {event.name}"
                        log_event(message)
                        print_colored(message, 'green')
                    elif flag == flags.DELETE:
                        message = f"Deleted: {event.name}"
                        log_event(message)
                        print_colored(message, 'red')
            time.sleep(1)
    except KeyboardInterrupt:
        print_colored("Stopping monitoring.", 'yellow')

if __name__ == "__main__":
    path_to_monitor = input("Enter the path to monitor (e.g. /home/user/Documents): ")
    if os.path.isdir(path_to_monitor):
        main(path_to_monitor)
    else:
        print_colored("Invalid directory path.", 'red')
