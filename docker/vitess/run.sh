#!/bin/bash
# 1 PRIMARY + 2 REPLICA, tuned for Docker Desktop on Apple Silicon.
# https://vitess.io/docs/24.0/get-started/vttestserver-docker-image/

/vt/setup_vschema_folder.sh "$KEYSPACES" "$NUM_SHARDS"

if [[ -z $MYSQL_MAX_CONNECTIONS ]]; then
  MYSQL_MAX_CONNECTIONS=50
fi
cat >> /vt/config/mycnf/test-suite.cnf <<EOF
max_connections = ${MYSQL_MAX_CONNECTIONS}
innodb_buffer_pool_size = 32M
innodb_log_buffer_size = 4M
performance_schema = OFF
table_open_cache = 64
thread_cache_size = 4
EOF

rm -vf "$VTDATAROOT"/"$tablet_dir"/{mysql.sock,mysql.sock.lock}

exec /vt/bin/vttestserver \
  --port "$PORT" \
  --keyspaces "$KEYSPACES" \
  --num-shards "$NUM_SHARDS" \
  --mysql-bind-host "${MYSQL_BIND_HOST:-127.0.0.1}" \
  --vtcombo-bind-host "${VTCOMBO_BIND_HOST:-127.0.0.1}" \
  --mysql-server-version "${MYSQL_SERVER_VERSION:-$1}" \
  --charset "${CHARSET:-utf8mb4}" \
  --foreign-key-mode "${FOREIGN_KEY_MODE:-allow}" \
  --enable-online-ddl="${ENABLE_ONLINE_DDL:-true}" \
  --enable-direct-ddl="${ENABLE_DIRECT_DDL:-true}" \
  --planner-version="${PLANNER_VERSION:-gen4}" \
  --vschema-ddl-authorized-users=% \
  --tablet-refresh-interval "${TABLET_REFRESH_INTERVAL:-10s}" \
  --schema-dir="/vt/schema/" \
  --data-dir=/vt/vtdataroot/ \
  --persistent-mode \
  --tablet-hostname=vitess \
  --replica-count=3 \
  --rdonly-count=0 \
  --gateway-initial-tablet-timeout=180s
