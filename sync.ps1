$source = "f:\Documents\(07)Obsidian\obsidian_folder\heim\100 Quartz"
$destination = "f:\Documents\myquartz\homepage\quartz\content"

Write-Host "Copying files from Obsidian vault to Quartz content folder..." -ForegroundColor Cyan

# Use Robocopy to mirror the directory. 
# /MIR mirrors the directory (copies all and deletes missing)
# /MT:8 enables multi-threading for faster copy
# /XD excludes the .obsidian config directory
# /R:3 /W:1 retries up to 3 times, waiting 1 second between retries in case a file is temporarily locked
# /NDL hide directory logging
# /NJH /NJS hide job header and summary
robocopy.exe $source $destination /MIR /MT:8 /XD ".obsidian" /R:3 /W:1 /NDL /NJH /NJS

# Robocopy exit codes: anything under 8 is a success
if ($LASTEXITCODE -lt 8) {
    Write-Host "Copy successful!" -ForegroundColor Green
    Write-Host "Starting Quartz sync..." -ForegroundColor Cyan
    
    # We reset the last exit code so that Node doesn't inherit robocopy's exit code
    $global:LASTEXITCODE = 0 
    
    npx quartz sync
} else {
    Write-Host "Failed to copy files. Robocopy exit code: $LASTEXITCODE" -ForegroundColor Red
}
