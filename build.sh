#!/bin/bash
set -e

echo "⚙️ Building Auto-RDP Docker image..."
docker build -t auto-rdp .

echo "🚀 Running Auto-RDP container..."
docker run -it --privileged auto-rdp
