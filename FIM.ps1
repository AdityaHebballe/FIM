Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"

# Add error checking
$response = Read-Host "Please enter 'A' or 'B'"
Write-Host ""

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}


if ($response -eq "A".ToUpper()) {
    # Calulate Hash from the target files and store in baseline.txt
    # Collect all files in target folder
    $files = Get-ChildItem -Path ".\Files" 
    # For file, calculate the hash, and write and write to baseline.txt

    foreach ($f in $files){
        Write-Output $f
    }
} elseif ($response -eq "B".ToUpper()) {
    # Begin monitoring files with saved Baseline
    Write-Host "Read existing baseline.txt, start monitoring files." -ForegroundColor Yellow
} else {
    Write-Host "Invalid input. Please enter 'A' or 'B'"
}

