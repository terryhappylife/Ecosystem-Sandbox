# 自动生成 music-manifest.js
# 扫描 music/background/Intro/ 与 music/background/middle/ 下的 .mp3 文件
$base = Split-Path -Parent $MyInvocation.MyCommand.Definition
$introDir = Join-Path $base "music\background\Intro"
$middleDir = Join-Path $base "music\background\middle"
$outFile = Join-Path $base "music-manifest.js"

function Get-TrackLines($dir) {
    $tracks = @()
    if (Test-Path $dir) {
        $tracks = Get-ChildItem -Path $dir -Filter *.mp3 | Sort-Object Name | ForEach-Object {
            $rel = $_.FullName.Substring($base.Length + 1).Replace('\', '/')
            "    '$rel'"
        }
    }
    return $tracks
}

$introTracks = @(Get-TrackLines $introDir)
$middleTracks = @(Get-TrackLines $middleDir)

$lines = [System.Collections.ArrayList]@()
[void]$lines.Add("// 音乐清单，由 update-music-manifest.bat / update-music-manifest.sh 自动生成")
[void]$lines.Add("// 新增/替换音乐后，重新运行脚本即可，无需修改 HTML/JS")
[void]$lines.Add("const MUSIC_TRACKS={")
[void]$lines.Add("  intro:[")
for ($i = 0; $i -lt $introTracks.Count; $i++) {
    $line = $introTracks[$i]
    if ($i -lt $introTracks.Count - 1) { $line += "," }
    [void]$lines.Add($line)
}
[void]$lines.Add("  ],")
[void]$lines.Add("  middle:[")
for ($i = 0; $i -lt $middleTracks.Count; $i++) {
    $line = $middleTracks[$i]
    if ($i -lt $middleTracks.Count - 1) { $line += "," }
    [void]$lines.Add($line)
}
[void]$lines.Add("  ]")
[void]$lines.Add("};")

$lines -join "`n" | Out-File -FilePath $outFile -Encoding UTF8
Write-Host "已生成 $outFile"
