#!/bin/bash
set -e

# 🎨 Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear

# 🚀 Banner
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║     ✈️  Auto RDP + Port Forwarding Installer 🚀         ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"
sleep 1

# 🔄 Animation helper
animate() {
    local msg=$1
    echo -ne "   ${YELLOW}${msg}${NC}"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.5
    done
    echo ""
}

# 🔑 Ask for RDP password
echo -ne "${CYAN}👉 Enter your RDP password: ${NC}"
read -s RDP_PASS
echo ""
echo -ne "${CYAN}👉 Confirm your RDP password: ${NC}"
read -s RDP_PASS2
echo ""

if [ "$RDP_PASS" != "$RDP_PASS2" ]; then
    echo -e "${RED}❌ Passwords do not match. Please run installer again.${NC}"
    exit 1
fi

# 🔧 Install dependencies
animate "Updating system & installing dependencies"
apt update -y >/dev/null 2>&1
apt install -y xfce4 xfce4-goodies xrdp ssh sshpass git curl sudo >/dev/null 2>&1

# 🖥️ Setup RDP user
animate "Configuring RDP user"
echo "root:$RDP_PASS" | chpasswd
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# ▶️ Enable services
animate "Enabling services"
systemctl enable xrdp >/dev/null 2>&1 || true
service ssh restart
service dbus start
service xrdp start

# 📦 Clone port-forwarding-tool
animate "Cloning port-forwarding-tool"
git clone https://github.com/hycroedev/port-forwarding-tool.git /opt/port-forwarding-tool >/dev/null 2>&1 || true

cd /opt/port-forwarding-tool
chmod +x install.sh
./install.sh >/dev/null 2>&1

# 🔗 Create tunnel for RDP (3389)
animate "Creating RDP tunnel"
TUNNEL_OUTPUT=$(port add 3389 2>&1 || true)

# Extract remote port from tunnel output
REMOTE_IP=$(echo "$TUNNEL_OUTPUT" | grep -oP '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
REMOTE_PORT=$(echo "$TUNNEL_OUTPUT" | grep -oP '\d{4,5}' | tail -n1)

clear
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo -e "${CYAN}➡️  Connect using Windows Remote Desktop (mstsc):${NC}"
echo -e "   ${YELLOW}$REMOTE_IP:$REMOTE_PORT${NC}"
echo ""
echo -e "   Username: ${CYAN}root${NC}"
echo -e "   Password: ${CYAN}$RDP_PASS${NC}"
echo ""
echo -e "${GREEN}🎉 Enjoy your RDP VPS!${NC}"
