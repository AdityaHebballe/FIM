import os
import time
import hashlib

# Function to calculate the hash of a file
def get_file_hash(filepath):
    hasher = hashlib.sha512()
    with open(filepath, 'rb') as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()

# Function to erase the existing baseline file if it exists
def erase_baseline_if_exists(baseline_path):
    if os.path.exists(baseline_path):
        os.remove(baseline_path)

def main():
    baseline_path = "baseline.txt"

    print("\nWhat would you like to do?")
    print("A) Collect new Baseline?")
    print("B) Begin monitoring files with saved Baseline?")
    
    response = input("Please enter 'A' or 'B': ").strip().upper()
    print("")

    if response == "A":
        # Delete existing baseline.txt if it exists
        erase_baseline_if_exists(baseline_path)

        # Collect all files in the target folder
        files = os.listdir('./Files')
        
        # Calculate hash for each file and write to baseline.txt
        with open(baseline_path, 'a') as baseline_file:
            for filename in files:
                filepath = os.path.join('./Files', filename)
                file_hash = get_file_hash(filepath)
                baseline_file.write(f"{filepath}|{file_hash}\n")

    elif response == "B":
        # Load file|hash pairs from baseline.txt into a dictionary
        file_hash_dictionary = {}
        with open(baseline_path, 'r') as baseline_file:
            for line in baseline_file:
                parts = line.strip().split('|')
                file_hash_dictionary[parts[0]] = parts[1]

        # Initialize sets to track reported files to prevent spam
        reported_created_files = set()
        reported_modified_files = set()
        reported_deleted_files = set()

        print("Read existing baseline.txt, start monitoring files.")

        while True:
            time.sleep(1)  
            files = os.listdir('./Files')

            for filename in files:
                filepath = os.path.join('./Files', filename)
                file_hash = get_file_hash(filepath)

                # Check for new files
                if filepath not in file_hash_dictionary:
                    if filepath not in reported_created_files:
                        print(f"File {filepath} has been created.")
                        reported_created_files.add(filepath) 
                else:
                    # Check for modified files
                    if file_hash_dictionary[filepath] != file_hash:
                        if filepath not in reported_modified_files:
                            print(f"File {filepath} has been modified!")
                            reported_modified_files.add(filepath) 

            # Check for deleted files
            for key in list(file_hash_dictionary.keys()):
                if not os.path.exists(key):
                    if key not in reported_deleted_files:
                        print(f"File {key} has been deleted.")
                        reported_deleted_files.add(key)  
    else:
        print("Invalid input. Please enter 'A' or 'B'")

if __name__ == "__main__":
    main()
