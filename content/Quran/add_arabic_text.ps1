$quranDir = "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran"
$textFile = Join-Path $quranDir "quran-simple-plain.txt"

$verses = @{}
Get-Content $textFile -Encoding UTF8 | ForEach-Object {
    $line = $_.Trim()
    if ($line) {
        $parts = $line -split '\|'
        if ($parts.Length -ge 3) {
            $surahNum = [int]$parts[0]
            $verseNum = [int]$parts[1]
            $text = $parts[2]
            
            if (-not $verses.ContainsKey($surahNum)) {
                $verses[$surahNum] = @{}
            }
            $verses[$surahNum][$verseNum] = $text
        }
    }
}

Write-Host "Loaded verses for $($verses.Keys.Count) Surahs."

$files = Get-ChildItem -Path $quranDir -Filter "*.md" | Where-Object { $_.Name -match "^(\d+)-" }

foreach ($file in $files) {
    if ($file.Name -match "^(\d+)-") {
        $surahNum = [int]$matches[1]
        
        if ($verses.ContainsKey($surahNum)) {
            $surahVerses = $verses[$surahNum]
            $lines = [System.IO.File]::ReadAllLines($file.FullName)
            $newLines = @()
            $changed = $false
            $addedCount = 0
            
            for ($i = 0; $i -lt $lines.Length; $i++) {
                $line = $lines[$i]
                $newLines += $line
                
                if ($line.Trim() -match '^(#{1,3})\s+[vV]erse\s+(\d+)\s*$') {
                    $verseNum = [int]$matches[2]
                    
                    if ($surahVerses.ContainsKey($verseNum)) {
                        $alreadyInjected = $false
                        for ($j = 1; $j -le 3; $j++) {
                            if (($i + $j) -lt $lines.Length -and $lines[$i+$j] -match 'class="quran-arabic"') {
                                $alreadyInjected = $true
                                break
                            }
                        }
                        
                        if (-not $alreadyInjected) {
                            $arabicText = $surahVerses[$verseNum]
                            $span = "<span dir=`"rtl`" class=`"quran-arabic`" style=`"display:block; font-size:2rem;`">$arabicText</span>"
                            $newLines += $span
                            $newLines += ""
                            $changed = $true
                            $addedCount++
                        }
                    }
                }
            }
            
            if ($changed) {
                # Determine encoding: keep UTF8 NO BOM
                $utf8NoBom = New-Object System.Text.UTF8Encoding $False
                [System.IO.File]::WriteAllLines($file.FullName, $newLines, $utf8NoBom)
                Write-Host "Updated $($file.Name): Added $addedCount verses."
            }
        }
    }
}
Write-Host "Finished processing."
