$files = Get-ChildItem -Path "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran\" -Filter "*.md" | Where-Object { $_.Name -ne "all.md" -and $_.Name -ne "Gameplan.md" }

foreach ($file in $files) {
    Write-Host "Processing $($file.Name)..."
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Remove existing ^verse- tags so we don't double them up
    $content = $content -replace "(?m)^\^verse-\d+\r?\n*", ""
    
    $lines = $content -split "`r?\n"
    $newLines = New-Object System.Collections.Generic.List[string]
    $currentVerse = ""
    
    foreach ($line in $lines) {
        if ($line -match '(?i)^#+\s*verse\s*(\d+)') {
            $currentVerse = $matches[1]
        }
        
        if ($line -match '(?i)^###\s*(thoughts|Reflection)') {
            if ($currentVerse) {
                if ($newLines.Count -gt 0 -and $newLines[$newLines.Count-1].Trim() -eq "") {
                    $newLines[$newLines.Count-1] = "^verse-$currentVerse"
                    $newLines.Add("")
                } else {
                    $newLines.Add("^verse-$currentVerse")
                    $newLines.Add("")
                }
            }
        }
        
        $newLines.Add($line)
    }
    
    Set-Content -Path $file.FullName -Value ($newLines -join "`n") -Encoding UTF8
}
Write-Host "Done formatting files."
