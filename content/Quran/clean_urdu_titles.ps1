$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
$dir = "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran"
$files = Get-ChildItem -Path $dir -Filter "*.md"
$contentUpdated = 0

foreach ($file in $files) {
    if ($file.Name -match "^(\d+)-") {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        
        # Match only the urdu_title line
        if ($content -match "(?m)^urdu_title:\s*(.+)$") {
            $oldTitle = $matches[1]
            
            # Remove Arabic diacritics \u064B-\u065F and superscript Alef \u0670
            $cleanedTitle = [System.Text.RegularExpressions.Regex]::Replace($oldTitle, "[\u064B-\u065F\u0670]", "")
            
            # Replace Alef Wasla (\u0671) with standard Alef (\u0627)
            $cleanedTitle = [System.Text.RegularExpressions.Regex]::Replace($cleanedTitle, "\u0671", "$([char]0x0627)")
            
            if ($oldTitle -cne $cleanedTitle) {
                $newContent = [regex]::Replace($content, "(?m)^urdu_title:\s*\Q$oldTitle\E$", "urdu_title: $cleanedTitle")
                
                if ($newContent -cne $content) {
                    [System.IO.File]::WriteAllText($file.FullName, $newContent, $Utf8NoBomEncoding)
                    Write-Host "Cleaned $($file.Name): $cleanedTitle"
                    $contentUpdated++
                }
            }
        }
    }
}

Write-Host "Finished! Cleaned diacritics in $contentUpdated files."
