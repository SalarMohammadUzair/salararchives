$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
$dir = "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran"
$jsonPath = Join-Path $dir "surah_translations.json"

$jsonText = [System.IO.File]::ReadAllText($jsonPath)
$translations = ConvertFrom-Json $jsonText

$files = Get-ChildItem -Path $dir -Filter "*.md"
$contentUpdated = 0

foreach ($file in $files) {
    if ($file.Name -match "^(\d+)-") {
        $surahNumber = $matches[1]
        
        $surahData = $translations."$surahNumber"
        if ($null -ne $surahData) {
            $enName = $surahData.en
            $urName = $surahData.ur
            
            $content = [System.IO.File]::ReadAllText($file.FullName)
            
            if ($content -match "en_translation:") {
                continue
            }
            
            $lineEnding = "`n"
            if ($content -match "`r`n") { $lineEnding = "`r`n" }
            
            $script:boundaryCount = 0
            $script:ur = $urName
            $script:en = $enName
            $script:lineEnding = $lineEnding
            
            $newContent = [regex]::Replace($content, "(?m)^---$", {
                param($match)
                $script:boundaryCount++
                if ($script:boundaryCount -eq 2) {
                    return "en_translation: $($script:en)$($script:lineEnding)ur_translation: $($script:ur)$($script:lineEnding)---"
                }
                return $match.Value
            })
            
            if ($newContent -cne $content -and $newContent.Length -gt 0) {
                [System.IO.File]::WriteAllText($file.FullName, $newContent, $Utf8NoBomEncoding)
                $contentUpdated++
            }
        }
    }
}
Write-Host "Updated $contentUpdated files with translations."
