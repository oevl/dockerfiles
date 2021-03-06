#!/bin/sh

if [ -z "$CLIENT_ADDRESS" ]; then
  echo "\$CLIENT_ADDRESS must be provided" 
  exit 1
fi

if [ -z "$CLIENT_NAME" ]; then
  echo "\$CLIENT_NAME must be provided" 
  exit 1
fi

if [ -z "$SUB" ]; then
  echo "\$SUB must be provided" 
  exit 1
fi

if [ -z "$RABBITMQ_HOST" ]; then
  echo "\$RABBITMQ_HOST must be provided" 
  exit 1
fi

SUBSCRIPTIONS="`echo $SUB|sed s/,/\\",\\"/g`"

cat << EOF > /etc/sensu/config.json
{
  "client": {
    "name": "$CLIENT_NAME",
    "address": "$CLIENT_ADDRESS",
    "subscriptions": ["$SUBSCRIPTIONS"],
    "keepalive": {
      "thresholds": {
        "warning": 60,
        "critical": 100
      },
    "refresh": 300
    }
  },
  "rabbitmq": {
    "host": "$RABBITMQ_HOST",
    "port": $RABBITMQ_PORT,
    "vhost": "$RABBITMQ_VHOST",
    "user": "$RABBITMQ_USER",
    "password": "$RABBITMQ_PASS",
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    }
  }
}
EOF

echo "Running sensu config:"
cat /etc/sensu/config.json

exec /opt/sensu/bin/sensu-client -v -c /etc/sensu/config.json -d /conf.d 
