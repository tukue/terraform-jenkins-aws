#!/bin/bash
set -euo pipefail

yum update -y
yum install -y docker curl

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

mkdir -p /opt/grafana/provisioning/datasources
mkdir -p /opt/grafana/dashboards

cat > /opt/grafana/provisioning/datasources/datasource.yml <<EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    uid: prometheus
    access: proxy
    url: ${prometheus_url}
    isDefault: true
    editable: true
EOF

cat > /opt/grafana/grafana.ini <<EOF
[analytics]
check_for_updates = false

[security]
admin_user = ${admin_user}
admin_password = ${admin_password}

[auth.anonymous]
enabled = false
EOF

docker rm -f grafana || true
docker run -d \
  --name grafana \
  --restart unless-stopped \
  -p 3000:3000 \
  -v /opt/grafana/provisioning:/etc/grafana/provisioning:ro \
  -v /opt/grafana/dashboards:/var/lib/grafana/dashboards:ro \
  -v /opt/grafana/grafana.ini:/etc/grafana/grafana.ini:ro \
  grafana/grafana:${grafana_version}
