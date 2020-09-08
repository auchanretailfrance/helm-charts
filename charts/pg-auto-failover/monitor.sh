#!/usr/bin/env bash
set -euo pipefail

PGCTL="/usr/lib/postgresql/$PG_MAJOR/bin/pg_ctl"

cp -R /opt/tls-secret /tmp/tls-secret
chown -R postgres /tmp/tls-secret

# Check if monitor DB was initilized
if [ ! -f $PGDATA/PG_VERSION ]; then
  if [ ! -e $PGDATA ]; then
    mkdir $PGDATA
  fi  
  chown -R postgres $PGHOME
  chown -R postgres $PGDATA
  echo
  echo "Creating monitor ..."
  echo
  MONITOR_FQDN="$HEADLESS_MONITOR_SERVICE.$K8S_NAMESPACE.svc.cluster.local"
  gosu postgres pg_autoctl create monitor \
    --pgctl $PGCTL \
    --hostname $MONITOR_FQDN \
    --skip-pg-hba \
    --ssl-ca-file /tmp/tls-secret/ca.crt \
    --server-cert /tmp/tls-secret/tls.crt \
    --server-key /tmp/tls-secret/tls.key

  echo
  echo "Configuring monitor ..."
  echo
  echo "include '/opt/configmap/postgresql.conf'" >> $PGDATA/postgresql.conf
  echo "include '/opt/configmap/custom-postgresql.conf'" >> $PGDATA/postgresql.conf  
  
  echo
  echo "Temporary starting monitor ..."
  echo
  gosu postgres $PGCTL --wait start
  gosu postgres psql --dbname pg_auto_failover --command "alter user autoctl_node password '$AUTOCTL_NODE_PASSWORD';"
  echo
  echo "Stopping temporary started monitor ..."
  echo
  gosu postgres $PGCTL stop
fi

echo
echo "Starting monitor ..."
echo
gosu postgres pg_autoctl run