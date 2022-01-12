#!/bin/bash

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cd /etc/yum.repos.d/

cat > logstash.repo << EOF
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum -y install logstash-7.16.1

usermod -a -G logstash ec2-user

export LS_JAVA_OPTS="-Xms1g -Xmx1g -XX:ParallelGCThreads=1"

cd /etc/logstash/conf.d

cp /parsers/* .

/usr/share/logstash/bin/logstash-plugin install logstash-filter-elapsed
/usr/share/logstash/bin/logstash-plugin install --version 7.0.1 logstash-output-amazon_es

mkdir ~/kibana_objects
cd ~/kibana_objects
aws s3 cp --recursive s3://${deployment_bucket}/monitoring/ .
for FILE in *; do curl -X POST "https://${es_endpoint}/_plugin/kibana/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" --form file=@$FILE; done

service logstash start
