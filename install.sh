#!/bin/bash

version=1.5.0

arch=`uname -s -m`
if [[ $arch == "Linux aarch64" ]]; then
  variant="linux-arm64"
elif [[ $arch == "Linux x86_64" ]]; then
  variant="linux-amd64"
else
  echo Unknown variant $arch
  exit 1
fi

name="node_exporter-${version}.${variant}"
ball="${name}.tar.gz"
url="https://github.com/prometheus/node_exporter/releases/download/v${version}/${ball}"

cd /tmp
if ! curl -sLo "$ball" "$url"; then
  echo "Failed to download $ball from $url"
  exit 1
fi

tar xzf "$ball"
if [[ ! -x "$name/node_exporter" ]]; then
  echo "Cannot find node_exporter executable"
  exit 1
fi
sudo cp "$name/node_exporter" /usr/local/bin

sudo useradd --no-create-home --system --shell /usr/sbin/nologin node_exporter || true

sudo tee /etc/systemd/system/node-exporter.service <<'EOF' >/dev/null
[Unit]
Description=Prometheus Node Exporter Service
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable node-exporter --now
systemctl status node-exporter
