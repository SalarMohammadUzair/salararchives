$indexPath = "f:\Downloads\index.txt"
$quranDir = "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran"

$lines = [System.IO.File]::ReadAllLines($indexPath)
$embeds = @{}

foreach ($line in $lines) {
    if ($line.Trim() -eq "") { continue }
    if ($line -match "\| Surah (\d+) Ayat ") {
        $surah = [int]$matches[1]
        
        $parts = $line.Split("|")
        $url = $parts[0].Trim()
        $videoId = $url.Substring($url.IndexOf("embed/") + 6)
        $desc = $parts[1].Trim()
        
        if (-not $embeds.Contains($surah)) {
            $embeds[$surah] = @{}
        }
        
        if ($desc -match "Ayat\s+([\d\s&,-]+)") {
            $ayatsStr = $matches[1].Trim()
            if ($ayatsStr -match "-") {
                $bounds = $ayatsStr.Split("-") | ForEach-Object { $_.Trim() }
                if ($bounds.Length -eq 2 -and [int]::TryParse($bounds[0], [ref]0) -and [int]::TryParse($bounds[1], [ref]0)) {
                    for ($a = [int]$bounds[0]; $a -le [int]$bounds[1]; $a++) {
                        $embeds[$surah][$a] = $videoId
                    }
                }
            } else {
                $ayatsStr = $ayatsStr.Replace('&', ',').Replace('-', ',')
                $ayats = $ayatsStr.Split(",") | ForEach-Object { $_.Trim() }
                foreach ($ayat in $ayats) {
                    if ([int]::TryParse($ayat, [ref]0)) {
                        $embeds[$surah][[int]$ayat] = $videoId
                    }
                }
            }
        }
    }
}

Write-Host "Parsed index.txt successfully."

$files = Get-ChildItem -Path $quranDir -Filter "*.md"
$totalChangedFiles = 0
$totalEmbeds = 0

foreach ($file in $files) {
    if ($file.Name -match "^(\d+)-") {
        $surahNum = [int]$matches[1]
        
        if ($embeds.Contains($surahNum)) {
            $surahEmbeds = $embeds[$surahNum]
            $content = [System.IO.File]::ReadAllText($file.FullName)
            $changed = 0
            
            $keys = $surahEmbeds.Keys | Sort-Object
            foreach ($k in $keys) {
                $vId = $surahEmbeds[$k]
                
                $pattern = "(?m)^(\^verse-$k)(\r?\n)(?!<div)"
                
                if ($content -match $pattern) {
                    $nl = $matches[2]
                    $div = "<div style=""position:relative;width:100%;padding-bottom:56.25%;height:0;overflow:hidden;cursor:pointer"" onclick=""(function(c){{c.innerHTML='<iframe src=\'https://www.youtube.com/embed/$vId?autoplay=1\' style=\'position:absolute;top:0;left:0;width:100%;height:100%;border:none\' allow=\'autoplay;encrypted-media\' allowfullscreen></iframe>'}})(this)"">$nl  <img src=""https://img.youtube.com/vi/$vId/maxresdefault.jpg"" style=""position:absolute;top:0;left:0;width:100%;height:100%;object-fit:cover"">$nl  <span style=""position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:3.5rem;color:#fff;text-shadow:0 0 20px rgba(0,0,0,0.8);pointer-events:none"">▶</span>$nl</div>$nl"
                    
                    $replacement = "`$1`$2" + $div
                    $content = [regex]::Replace($content, $pattern, $replacement)
                    $changed++
                }
            }
            
            if ($changed -gt 0) {
                [System.IO.File]::WriteAllText($file.FullName, $content)
                Write-Host "Updated $($file.Name): Embedded $changed videos."
                $totalChangedFiles++
                $totalEmbeds += $changed
            }
        }
    }
}

Write-Host "All notes processed. Updated $totalChangedFiles files with $totalEmbeds new embeds total."
