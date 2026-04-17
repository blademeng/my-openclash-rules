#!/usr/bin/env bash
# 从 Aethersailor 上游拉取最新 ini，把 private/direct-rules.ini
# 插入到 [custom] 段后的第一条 ruleset= 之前（即最高优先级位置）。
set -euo pipefail

UPSTREAM_REPO="Aethersailor/Custom_OpenClash_Rules"
UPSTREAM_BRANCH="main"
VARIANTS=("Custom_Clash" "Custom_Clash_Full" "Custom_Clash_Lite" "Custom_Clash_GFW" "Custom_Clash_Mainland")

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRIV="${ROOT}/private/direct-rules.ini"
OUT_DIR="${ROOT}/cfg"
mkdir -p "${OUT_DIR}"

[ -f "${PRIV}" ] || { echo "ERROR: ${PRIV} not found"; exit 1; }

for v in "${VARIANTS[@]}"; do
  url="https://raw.githubusercontent.com/${UPSTREAM_REPO}/${UPSTREAM_BRANCH}/cfg/${v}.ini"
  dst="${OUT_DIR}/${v}.ini"
  tmp="$(mktemp)"
  echo "==> ${v}.ini"
  if ! curl -fsSL --retry 3 --retry-delay 2 "${url}" -o "${tmp}"; then
    echo "   (skip: ${url} not found)"
    rm -f "${tmp}"
    continue
  fi

  awk -v priv="${PRIV}" '
    BEGIN { in_custom = 0; injected = 0 }
    /^\[custom\]/ { in_custom = 1; print; next }
    /^\[[^]]+\]/  { in_custom = 0 }
    {
      if (in_custom && !injected && $0 ~ /^ruleset=/) {
        print ";=============================================="
        print ";  PRIVATE DIRECT RULES (auto-injected, DO NOT EDIT HERE)"
        print ";  Source: private/direct-rules.ini"
        print ";  Injected at: " strftime("%Y-%m-%dT%H:%M:%SZ", systime(), 1)
        print ";=============================================="
        while ((getline line < priv) > 0) print line
        close(priv)
        print ";=============================================="
        print ""
        injected = 1
      }
      print
    }
  ' "${tmp}" > "${dst}"

  rm -f "${tmp}"
  echo "    wrote ${dst}"
done

echo "Done."
