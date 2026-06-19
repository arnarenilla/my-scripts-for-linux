#!/usr/bin/env bash

set -e

# Detect architecture
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)
    ARCH="amd64"
    ;;
  aarch64|arm64)
    ARCH="arm64"
    ;;
  *)
    echo "❌ Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

echo "✔ Detected architecture: $ARCH"

# Get latest version
VERSION=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep tag_name | cut -d '"' -f 4)

echo "✔ Latest version: $VERSION"

cd /tmp

# Download
FILE="node_exporter-${VERSION#v}.linux-${ARCH}.tar.gz"
URL="https://github.com/prometheus/node_exporter/releases/download/${VERSION}/${FILE}"

echo "⬇ Downloading $URL"
wget -q $URL

# Extract
tar xvf $FILE
cd node_exporter-*.linux-${ARCH}

# Create user
if ! id "node_exporter" &>/dev/null; then
  useradd --no-create-home --shell /bin/false node_exporter
  echo "✔ Created user node_exporter"
fi

# Move binary
cp node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter
chmod +x /usr/local/bin/node_exporter

# Create systemd service
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload and start
systemctl daemon-reload
systemctl enable node_exporter
systemctl restart node_exporter

echo "🚀 Node Exporter installed and running!"

# Show status
systemctl status node_exporter --no-pager

# Test endpoint
echo "🌐 Testing metrics endpoint..."
sleep 2
curl -s http://localhost:9100/metrics | head -n 10
