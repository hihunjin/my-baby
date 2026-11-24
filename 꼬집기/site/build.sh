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
DESC="10개월 아기가 엄마·아빠를 꼬집을 때, 장기화되기 전에 매번 똑같이 반응하는 법과 예방·상담 기준을 공식 가이드와 발달 연구로 정리했습니다."

[ -f "$SRC" ] || { echo "없음: $SRC" >&2; exit 1; }
mkdir -p public

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
<meta name="theme-color" content="#F4EEE8" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#17120F" media="(prefers-color-scheme: dark)">
<meta property="og:type" content="article">
<meta property="og:locale" content="ko_KR">
<meta property="og:title" content="아기 꼬집기 대처">
<meta property="og:description" content="${DESC}">
<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>%E2%9C%8B</text></svg>">
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
