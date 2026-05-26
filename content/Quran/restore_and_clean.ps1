$source = "f:\Documents\myquartz\homepage\quartz\content\Quran\*.md"
$dest = "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran\"

Write-Host "Restoring files from backup..."
Copy-Item $source $dest -Force
Write-Host "Restoration complete."

$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
$files = Get-ChildItem -Path $dest -Filter "*.md"
$contentUpdated = 0

foreach ($file in $files) {
    if ($file.Name -match "^(\d+)-") {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        
        if ($content -match "(?m)^urdu_title:\s*(.+)$") {
            $oldTitle = $matches[1]
            
            $cleanedTitle = [System.Text.RegularExpressions.Regex]::Replace($oldTitle, "[\u064B-\u065F\u0670]", "")
            $cleanedTitle = $cleanedTitle.Replace([char]0x0671, [char]0x0627)
            
            if ($oldTitle -cne $cleanedTitle -and $oldTitle.Length -gt 0) {
                $escapedOldTitle = [regex]::Escape($oldTitle)
                $newContent = [regex]::Replace($content, "(?m)^urdu_title:\s*$escapedOldTitle`$", "urdu_title: $cleanedTitle")
                
                if ($newContent -ne $null -and $newContent -ne "") {
                    [System.IO.File]::WriteAllText($file.FullName, $newContent, $Utf8NoBomEncoding)
                    $contentUpdated++
                }
            }
        }
    }
}
Write-Host "Finished! Cleaned diacritics in $contentUpdated files."
