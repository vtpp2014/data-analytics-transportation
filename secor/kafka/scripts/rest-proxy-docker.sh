#!/bin/bash

sleep 15

rp_cfg_file="/etc/kafka-rest/kafka-rest.properties"

#: ${RP_ID:=1}
#: ${RP_PORT:=8082}
#: ${RP_SCHEMA_REGISTRY_URL:=http://$SCHEMA_REGISTRY_PORT_8081_TCP_ADDR:$SCHEMA_REGISTRY_PORT_8081_TCP_PORT}
#: ${RP_ZOOKEEPER_CONNECT:=$ZOOKEEPER_PORT_2181_TCP_ADDR:$ZOOKEEPER_PORT_2181_TCP_PORT}
#: ${RP_DEBUG:=false}

export RP_ID=1
export RP_PORT=9443
export RP_SCHEMA_REGISTRY_URL=http://localhost:8081
export RP_ZOOKEEPER_CONNECT=localhost:2181
export RP_DEBUG=false

# Download the config file, if given a URL
if [ ! -z "$RP_CFG_URL" ]; then
  echo "[RP] Downloading RP config file from ${RP_CFG_URL}"
  curl --location --silent --insecure --output ${rp_cfg_file} ${RP_CFG_URL}
  if [ $? -ne 0 ]; then
    echo "[RP] Failed to download ${RP_CFG_URL} exiting."
    exit 1
  fi
fi

echo '# Generated by rest-proxy-docker.sh' > ${rp_cfg_file}
for var in $(env | grep -v '^RP_CFG_' | grep '^RP_' | sort); do
  key=$(echo $var | sed -r 's/RP_(.*)=.*/\1/g' | tr A-Z a-z | tr _ .)
  value=$(echo $var | sed -r 's/.*=(.*)/\1/g')
  echo "${key}=${value}" >> ${rp_cfg_file}
done

# Fix for issue #77, PR #78: https://github.com/confluentinc/kafka-rest/pull/78/files
sed -i 's/\"kafka\"//' /usr/bin/kafka-rest-run-class

exec /usr/bin/kafka-rest-start ${rp_cfg_file}
