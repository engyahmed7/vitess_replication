#!/bin/bash
# Copy VTAdmin static build from vitess/lite into the shared volume (as root).
set -e

echo "Searching for VTAdmin web build in image..."
find /vt -name index.html 2>/dev/null | head -30 || true

if [ -d /vt/web/vtadmin/build ] && [ -f /vt/web/vtadmin/build/index.html ]; then
  SRC=/vt/web/vtadmin/build
elif [ -d /vt/web/vtadmin ] && [ -f /vt/web/vtadmin/index.html ]; then
  SRC=/vt/web/vtadmin
else
  echo "ERROR: no VTAdmin frontend found in vitess/lite:v24.0.2"
  ls -la /vt 2>/dev/null || true
  ls -la /vt/web 2>/dev/null || true
  exit 1
fi

echo "Copying from $SRC"
mkdir -p /out
rm -rf /out/*
cp -a "$SRC"/. /out/
# Help the UI find the API when opened at localhost:14201
printf '%s\n' 'window.env={VITE_VTADMIN_API_ADDRESS:"http://localhost:14200"};' > /out/config.js
ls -la /out | head -20
echo "assets-ready"
