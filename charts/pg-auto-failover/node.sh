#!/usr/bin/env bash
set -euo pipefail

PGCTL="/usr/lib/postgresql/$PG_MAJOR/bin/pg_ctl"
POD_INDEX=${POD_NAME##*-}
CANDIDATE_PRIORITY=50
if [ ${POD_INDEX} -eq 0 ]; then
  CANDIDATE_PRIORITY=100
fi

cp -R /opt/tls-secret /tmp/tls-secret
chown -R postgres /tmp/tls-secret

# Check if node DB was initilized
if [ ! -f $PGDATA/PG_VERSION ]; then
  if [ ! -e $PGDATA ]; then
    mkdir $PGDATA
  fi

  MONITOR_FQDN="$HEADLESS_MONITOR_SERVICE.$K8S_NAMESPACE.svc.cluster.local"
  chown -R postgres $PGHOME
  gosu postgres echo "$MONITOR_FQDN:5432:pg_auto_failover:autoctl_node:$AUTOCTL_NODE_PASSWORD" > $PGHOME/.pgpass
  gosu postgres echo "*:5432:*:pgautofailover_replicator:$PGAUTOFAILOVER_REPLICATOR_PASSWORD" >> $PGHOME/.pgpass
  chown postgres $PGHOME/.pgpass
  chmod 600 $PGHOME/.pgpass
  chown -R postgres $PGDATA
  
  echo
  echo "Creating node ..."
  echo
  gosu postgres pg_autoctl create postgres --skip-pg-hba --username postgres \
    --ssl-ca-file /tmp/tls-secret/ca.crt \
    --server-cert /tmp/tls-secret/tls.crt \
    --server-key /tmp/tls-secret/tls.key \
    --dbname $PGDATABASE \
    --monitor "postgres://autoctl_node@$MONITOR_FQDN:5432/pg_auto_failover?sslmode=verify-full&sslrootcert=/tmp/tls-secret/ca.crt" \
    --pgctl $PGCTL \
    --hostname $POD_NAME.$HEADLESS_NODE_SERVICE.$K8S_NAMESPACE.svc.cluster.local \
    --candidate-priority $CANDIDATE_PRIORITY \
    --name $POD_NAME

  echo
  echo "Configuring node ..."
  echo
  echo "include '/opt/configmap/postgresql.conf'" >> $PGDATA/postgresql.conf
  echo "include '/opt/configmap/custom-postgresql.conf'" >> $PGDATA/postgresql.conf
  
  if [ ${POD_INDEX} -eq 0 ]; then
    echo
    echo "Temporary starting node ..."
    echo
    gosu postgres $PGCTL --wait start
    gosu postgres psql --dbname $PGDATABASE --command "alter user pgautofailover_replicator password '$PGAUTOFAILOVER_REPLICATOR_PASSWORD';"
    gosu postgres psql --dbname $PGDATABASE --command "alter user postgres password '$POSTGRES_PASSWORD';"
    echo
    echo "Stopping temporary started monitor ..."
    echo
    gosu postgres $PGCTL stop
  fi
fi

echo
echo "Starting node ..."
echo
gosu postgres pg_autoctl run