#!/usr/bin/env bash
# content.html(아티팩트용 조각) → public/index.html(독립 실행 HTML)
#
# content.html 은 단일 원본입니다. 그대로 Claude 아티팩트로 배포할 수도 있고,
# 이 스크립트를 돌리면 Vercel 정적 배포용 완전한 HTML 문서가 만들어집니다.
#
#   ./build.sh          내용 수정 후 이걸 실행한 뒤 vercel --prod

set -euo pipefail
cd "$(dirname "$0")"

SRC="content.html"
OUT="public/index.html"
DESC="어린이집 첫 등원을 4주 전부터 30분 전까지 구간별로 정리한 체크리스트입니다. 아이 월령(6~24개월)에 맞는 주의사항이 함께 붙습니다."

[ -f "$SRC" ] || { echo "없음: $SRC" >&2; exit 1; }
mkdir -p public

# content.html 을 첫 </style> 기준으로 head 부분과 body 부분으로 나눈다
awk '/<\/style>/ && !done {print; done=1; exit} {print}' "$SRC" > .head.tmp
awk '/<\/style>/ && !done {done=1; next} done {print}' "$SRC" > .body.tmp

{
  cat <<HEAD
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="description" content="${DESC}">
<meta name="robots" content="noindex, nofollow">
<meta name="color-scheme" content="light dark">
<meta name="theme-color" content="#EDEFF7" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#101324" media="(prefers-color-scheme: dark)">
<meta property="og:type" content="article">
<meta property="og:locale" content="ko_KR">
<meta property="og:title" content="어린이집 첫 등원 준비">
<meta property="og:description" content="${DESC}">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>%F0%9F%8E%92</text></svg>">
<style>
  :root{
    color-scheme:light dark;
    padding-top:env(safe-area-inset-top,0px);
    padding-bottom:env(safe-area-inset-bottom,0px);
  }
  body{margin:0}
  img{max-width:100%}
  [hidden]{display:none!important}
</style>
HEAD
  cat .head.tmp
  echo "</head>"
  echo "<body>"
  cat .body.tmp
  echo "</body>"
  echo "</html>"
} > "$OUT"

rm -f .head.tmp .body.tmp
echo "빌드 완료: $OUT  ($(wc -c < "$OUT" | tr -d ' ') bytes)"
