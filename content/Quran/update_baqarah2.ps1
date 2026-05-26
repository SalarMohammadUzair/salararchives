$indexPath = "f:\Downloads\index.txt"
$baqarahPath = "f:\Documents\(07)Obsidian\obsidian_folder\heim\03 Archive\quartzsitefolder\Quran\2-Al-baqarah.md"

$lines = [System.IO.File]::ReadAllLines($indexPath)
$embeds = @{}

foreach ($line in $lines) {
    if ($line.Trim() -eq "") { continue }
    if ($line -match "\| Surah 2 Ayat ") {
        $parts = $line.Split("|")
        $url = $parts[0].Trim()
        $videoId = $url.Substring($url.IndexOf("embed/") + 6)
        $desc = $parts[1].Trim()
        
        if ($desc -match "Ayat\s+([\d\s&,-]+)") {
            $ayatsStr = $matches[1].Trim()
            if ($ayatsStr -match "-") {
                $bounds = $ayatsStr.Split("-") | ForEach-Object { $_.Trim() }
                if ($bounds.Length -eq 2 -and [int]::TryParse($bounds[0], [ref]0) -and [int]::TryParse($bounds[1], [ref]0)) {
                    for ($a = [int]$bounds[0]; $a -le [int]$bounds[1]; $a++) {
                        $embeds[$a] = $videoId
                    }
                }
            } else {
                $ayatsStr = $ayatsStr.Replace('&', ',').Replace('-', ',')
                $ayats = $ayatsStr.Split(",") | ForEach-Object { $_.Trim() }
                foreach ($ayat in $ayats) {
                    if ([int]::TryParse($ayat, [ref]0)) {
                        $embeds[[int]$ayat] = $videoId
                    }
                }
            }
        }
    }
}

Write-Host "Found $($embeds.Count) ayat embeds for Surah 2"

# Read whole file to preserve line endings
$content = [System.IO.File]::ReadAllText($baqarahPath)

$changed = 0
$keys = $embeds.Keys | Sort-Object

foreach ($k in $keys) {
    $vId = $embeds[$k]
    
    # We look for:
    # ^verse-$k\r\n
    # OR
    # ^verse-$k\n
    
    # regex match to capture the newline character(s)
    $pattern = "(?m)^(\^verse-$k)(\r?\n)(?!<div)"
    
    if ($content -match $pattern) {
        $nl = $matches[2]
        $div = "<div style=""position:relative;width:100%;padding-bottom:56.25%;height:0;overflow:hidden;cursor:pointer"" onclick=""(function(c){{c.innerHTML='<iframe src=\'https://www.youtube.com/embed/$vId?autoplay=1\' style=\'position:absolute;top:0;left:0;width:100%;height:100%;border:none\' allow=\'autoplay;encrypted-media\' allowfullscreen></iframe>'}})(this)"">$nl  <img src=""https://img.youtube.com/vi/$vId/maxresdefault.jpg"" style=""position:absolute;top:0;left:0;width:100%;height:100%;object-fit:cover"">$nl  <span style=""position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:3.5rem;color:#fff;text-shadow:0 0 20px rgba(0,0,0,0.8);pointer-events:none"">▶</span>$nl</div>$nl"
        
        $replacement = "`$1`$2" + $div
        $content = [regex]::Replace($content, $pattern, $replacement)
        $changed++
        Write-Host "Embedded $vId for Verse $k"
    } else {
        # Might already be embedded or verse not found
    }
}

if ($changed -gt 0) {
    [System.IO.File]::WriteAllText($baqarahPath, $content)
    Write-Host "Successfully embedded $changed videos."
} else {
    Write-Host "No changes made."
}
