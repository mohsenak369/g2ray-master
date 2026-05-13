#!/bin/bash
set -euo pipefail

XRAY_BIN="/usr/local/bin/xray"
TEMPLATE_CONFIG="/etc/xray/config.template.json"
RUNTIME_CONFIG="/tmp/config.json"

if [ ! -x "$XRAY_BIN" ]; then
  echo "Error: Xray binary not found at ${XRAY_BIN}" >&2
  exit 1
fi

if [ ! -f "$TEMPLATE_CONFIG" ]; then
  echo "Error: Template config not found at ${TEMPLATE_CONFIG}" >&2
  exit 1
fi

# 1) تولید UUID جدید برای هر بار ران شدن Codespace
UUID="$(cat /proc/sys/kernel/random/uuid)"

# 2) ساختن config بر اساس template
sed "s/__UUID__/${UUID}/g" \
  "$TEMPLATE_CONFIG" > "$RUNTIME_CONFIG"

echo ""
echo "=========================================="
echo "    Xray VLESS (XHTTP) on Codespaces"
echo "=========================================="
echo ""
echo "UUID (برای v2rayNG استفاده کن):"
echo "  ${UUID}"
echo ""

if [ -n "${CODESPACE_NAME:-}" ]; then
  # آدرس عمومی Codespaces روی پورت ۴۴۳
  ENDPOINT="${CODESPACE_NAME}-443.app.github.dev"
  echo "Endpoint:"
  echo "  ${ENDPOINT}:443"
  echo ""
  echo "مثال VLESS Link:"
  echo "  vless://${UUID}@${ENDPOINT}:443?encryption=none&security=none&type=http#codespace"
  echo ""
fi

echo "Starting Xray..."
exec "$XRAY_BIN" -config "$RUNTIME_CONFIG"
