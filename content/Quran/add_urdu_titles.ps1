$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
$response = Invoke-RestMethod -Uri "https://api.alquran.cloud/v1/surah"
$surahNames = @{}
foreach ($surah in $response.data) {
    $surahNames[$surah.number.ToString()] = $surah.name
}

$dir = "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran"
$files = Get-ChildItem -Path $dir -Filter "*.md"
$contentUpdated = 0

foreach ($file in $files) {
    if ($file.Name -match "^(\d+)-") {
        $surahNumber = $matches[1]
        
        if ($surahNames.ContainsKey($surahNumber)) {
            $urduName = $surahNames[$surahNumber]
            $content = [System.IO.File]::ReadAllText($file.FullName)
            
            # Skip if already has urdu_title
            if ($content -match "urdu_title:") {
                continue
            }
            
            # Detect line ending
            $lineEnding = "`n"
            if ($content -match "`r`n") { $lineEnding = "`r`n" }
            
            $script:boundaryCount = 0
            $script:urduName = $urduName
            $script:lineEnding = $lineEnding
            
            # Injection
            $newContent = [regex]::Replace($content, "^---$", {
                param($match)
                $script:boundaryCount++
                if ($script:boundaryCount -eq 2) {
                    return "urdu_title: $($script:urduName)$($script:lineEnding)---"
                }
                return $match.Value
            }, [System.Text.RegularExpressions.RegexOptions]::Multiline)
            
            if ($newContent -cne $content) {
                [System.IO.File]::WriteAllText($file.FullName, $newContent, $Utf8NoBomEncoding)
                Write-Host "Updated $($file.Name): injected urdu_title: $urduName"
                $contentUpdated++
            }
        }
    }
}

Write-Host "Finished! Updated $contentUpdated files."
