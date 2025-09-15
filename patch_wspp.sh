#!/usr/bin/env bash
set -euo pipefail

# Usage: patch_wspp.sh /path/to/websocketpp/include /path/to/mirror
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <patch-dir> <wspp-include-dir>" 
  exit 1
fi

MIRROR_DIR="$1"
WS_INCLUDE="$2"

# Helper to ensure target subdir exists
ensure_dir() {
  local tgt="$1"
  if [ ! -d "$tgt" ]; then
    echo "Creating directory: $tgt"
    mkdir -p "$tgt"
  fi
}

echo "Patching WebSocket++ at: $WS_INCLUDE"
echo "  from mirror:        $MIRROR_DIR"

# 1) endpoint.hpp
echo "Copying endpoint.hpp → $WS_INCLUDE/endpoint.hpp"
cp "$MIRROR_DIR/endpoint.hpp" "$WS_INCLUDE/endpoint.hpp"

# 2) logger/basic.hpp
ensure_dir "$WS_INCLUDE/logger"
echo "Copying logger/basic.hpp → $WS_INCLUDE/logger/basic.hpp"
cp "$MIRROR_DIR/logger/basic.hpp" "$WS_INCLUDE/logger/basic.hpp"

# 3) roles/server_endpoint.hpp
ensure_dir "$WS_INCLUDE/roles"
echo "Copying roles/server_endpoint.hpp → $WS_INCLUDE/roles/server_endpoint.hpp"
cp "$MIRROR_DIR/roles/server_endpoint.hpp" "$WS_INCLUDE/roles/server_endpoint.hpp"

# 4) transport/asio/connection.hpp
ensure_dir "$WS_INCLUDE/transport/asio"
echo "Copying transport/asio/connection.hpp → $WS_INCLUDE/transport/asio/connection.hpp"
cp "$MIRROR_DIR/transport/asio/connection.hpp" "$WS_INCLUDE/transport/asio/connection.hpp"

echo "Done."

