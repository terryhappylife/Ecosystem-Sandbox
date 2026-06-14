#!/usr/bin/env bash
# 自动生成 music-manifest.js
# 扫描 music/background/Intro/ 与 music/background/middle/ 下的 .mp3 文件
set -e

BASE="$(cd "$(dirname "$0")" && pwd)"
OUT="$BASE/music-manifest.js"

collect() {
  local dir="$1"
  local first=1
  if [ -d "$dir" ]; then
    find "$dir" -maxdepth 1 -type f -iname '*.mp3' | sort | while read -r f; do
      rel="${f#$BASE/}"
      rel="${rel//\\//}"
      if [ "$first" -eq 1 ]; then
        first=0
      else
        printf ",\n"
      fi
      printf "    '%s'" "$rel"
    done
  fi
  printf "\n"
}

{
  echo "// 音乐清单，由 update-music-manifest.bat / update-music-manifest.sh 自动生成"
  echo "// 新增/替换音乐后，重新运行脚本即可，无需修改 HTML/JS"
  echo "const MUSIC_TRACKS={"
  echo "  intro:["
  collect "$BASE/music/background/Intro"
  echo "  ],"
  echo "  middle:["
  collect "$BASE/music/background/middle"
  echo "  ]"
  echo "};"
} > "$OUT"

echo "已生成 $OUT"
