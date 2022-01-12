#!/bin/bash

echo "Setting up Rsyslog Configuration"
# Used for Rsyslog to send relevant logs to Logstash
sudo mkdir -p /etc/systemd/system/rsyslog.service.d/
{ echo "[Service]"; 
  echo "Environment=\"LOGSTASH_IP=${logstash_ip}\"";
  echo "Environment=\"HYDROVIS_APPLICATION=data_ingest\"";
} | sudo tee /etc/systemd/system/rsyslog.service.d/override.conf
sudo systemctl daemon-reload
sudo systemctl restart rsyslog

echo "Installing System Dependencies"
sudo yum -y install git postgresql12

echo "Installing HML Ingester"
aws s3 cp s3://${DEPLOYMENT_DATA_BUCKET}/ingest/owp-hml-ingester.tar.gz /home/ec2-user
tar -C /home/ec2-user -xzf /home/ec2-user/owp-hml-ingester.tar.gz

echo "Updating HML Ingester Configs"
RSCHEME=${RSCHEME}
RPORT=${RPORT}
RHOST=${RHOST}
RPASSWORD=${MQINGESTPASSWORD}
DBHOST=${DBHOST}
DBPASSWORD=${DBPASSWORD}

# Update configs
(echo "$RHOST"; echo "$RPASSWORD"; echo "$DBHOST"; echo "$DBPASSWORD") | sudo /home/ec2-user/owp-hml-ingester/update_configs.sh hydrovis.${HVLEnvironment}

echo "Building HML Ingester Dockers"
/usr/local/bin/docker-compose -f /home/ec2-user/owp-hml-ingester/docker-compose_hydrovis_${HVLEnvironment}.yml build

echo "Spinning up HML Ingester Dockers"
/usr/local/bin/docker-compose -f /home/ec2-user/owp-hml-ingester/docker-compose_hydrovis_${HVLEnvironment}.yml up -d

echo "Finished Setup"

