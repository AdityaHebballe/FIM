# Function to calculate the hash of a file
Function Get-File-Hash($filepath) {
    return Get-FileHash -Path $filepath -Algorithm SHA512
}

# Function to erase the existing baseline file if it exists
Function Erase-Baseline-If-Already-Exists {
    if (Test-Path ".\baseline.txt") {
        Remove-Item ".\baseline.txt"
    }
}

Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host "Please enter 'A' or 'B'"
Write-Host ""

if ($response -eq "A".ToUpper()) {
    # Delete existing baseline.txt if it exists
    Erase-Baseline-If-Already-Exists

    # Collect all files in target folder
    $files = Get-ChildItem -Path ".\Files"

    # Calculate hash for each file and write to baseline.txt
    foreach ($f in $files) {
        $hash = Get-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath ".\baseline.txt" -Append
    }

} elseif ($response -eq "B".ToUpper()) {
    # Load file|hash pairs from baseline.txt into a dictionary
    $fileHashDictionary = @{}
    Get-Content -Path ".\baseline.txt" | ForEach-Object {
        $parts = $_ -split "\|"
        $fileHashDictionary[$parts[0]] = $parts[1]
    }

    # Initialize hash tables to track reported files, this is to prevent the spamming of messages
    $reportedCreatedFiles = @{}
    $reportedModifiedFiles = @{}
    $reportedDeletedFiles = @{}

    Write-Host "Read existing baseline.txt, start monitoring files." -ForegroundColor Yellow

    while ($true) {
        Start-Sleep -Seconds 1
        $files = Get-ChildItem -Path ".\Files"

        foreach ($f in $files) {
            $hash = Get-File-Hash $f.FullName

            # Check for new files
            if (-not $fileHashDictionary.ContainsKey($hash.Path)) {
                if (-not $reportedCreatedFiles.ContainsKey($hash.Path)) {
                    Write-Host "File $($hash.Path) has been created." -ForegroundColor Green
                    $reportedCreatedFiles[$hash.Path] = $true  # Mark this file as reported
                }
            } 
            else {
                # Check for modified files
                if ($fileHashDictionary[$hash.Path] -ne $hash.Hash) {
                    if (-not $reportedModifiedFiles.ContainsKey($hash.Path)) {
                        Write-Host "File $($hash.Path) has been modified!!" -ForegroundColor Yellow
                        $reportedModifiedFiles[$hash.Path] = $true  # Mark this file as reported
                    }
                }
            }
        }

        # Check for deleted files
        foreach ($key in $fileHashDictionary.Keys) {
            if (-not (Test-Path -Path $key)) {
                if (-not $reportedDeletedFiles.ContainsKey($key)) {
                    Write-Host "File $($key) has been deleted." -ForegroundColor Red
                    $reportedDeletedFiles[$key] = $true  # Mark this file as reported
                }
            }
        }
    }
} else {
    Write-Host "Invalid input. Please enter 'A' or 'B'"
}
