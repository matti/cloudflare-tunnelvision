#!/usr/bin/env bash

set -eEuo pipefail

_on_error() {
  trap '' ERR
  line_path=$(caller)
  line=${line_path% *}
  path=${line_path#* }

  echo ""
  echo "ERR $path:$line $BASH_COMMAND exited with $1"
  exit 1
}
trap '_on_error $?' ERR

_shutdown() {
  trap '' TERM INT

  kill 0
  wait
  exit 0
}

trap _shutdown TERM INT

rm -rf "$HOME/.cloudflared" || true

mkdir -p "$HOME/.cloudflared"
echo "${TUNNELVISION_CLOUDFLARED_PEM}" > "$HOME/.cloudflared/cert.pem"

id=""
while true; do
  echo "list $TUNNELVISION_TUNNEL_NAME"

  id=$(cloudflared tunnel list --output json --name "$TUNNELVISION_TUNNEL_NAME" | jq -r ".[0].id")
  [[ "$id" != "" ]] && break

  cloudflared tunnel create \
    --secret "$TUNNELVISION_TUNNEL_SECRET" \
    "$TUNNELVISION_TUNNEL_NAME" || true
done
export TUNNELVISION_TUNNEL_ID="$id"

echo "id: ${TUNNELVISION_TUNNEL_ID}"

envsubst < /app/tunnel.template.json > "${HOME}/.cloudflared/${TUNNELVISION_TUNNEL_ID}.json"

while true; do
  cloudflared tunnel -f route dns "$TUNNELVISION_TUNNEL_NAME" "$TUNNELVISION_TUNNEL_DNS" && break
  sleep 1
done

exec cloudflared tunnel run --url "$TUNNELVISION_TUNNEL_UPSTREAM" "$TUNNELVISION_TUNNEL_NAME"
