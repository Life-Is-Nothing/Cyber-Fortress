#!/bin/bash
# Cyber-Fortress - Linux Hardening - ibramoha2
# Usage: sudo bash fortress.sh

[ "$EUID" -ne 0 ] && echo 'Executer en root' && exit 1

REPORT="/tmp/fortress_$(date +%Y%m%d_%H%M%S).txt"
echo "Fortress Report - $(date)" > "$REPORT"

echo '  Cyber-Fortress - Linux Hardening'
echo '  by ibramoha2 | github.com/ibramoha2'
echo ''

echo '[*] Mise a jour systeme...'
apt-get update -qq && apt-get upgrade -y -qq
echo '[+] Systeme a jour'

echo '[*] Installation paquets securite...'
apt-get install -y -qq fail2ban auditd ufw
echo '[+] Paquets installes'

echo '[*] Securisation SSH...'
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/.*X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
grep -q 'MaxAuthTries' /etc/ssh/sshd_config || echo 'MaxAuthTries 3' >> /etc/ssh/sshd_config
grep -q 'ClientAliveInterval' /etc/ssh/sshd_config || echo 'ClientAliveInterval 300' >> /etc/ssh/sshd_config
systemctl restart sshd
echo '[+] SSH securise'

echo '[*] Firewall UFW...'
ufw default deny incoming > /dev/null
ufw default allow outgoing > /dev/null
ufw allow ssh > /dev/null
ufw --force enable > /dev/null
echo '[+] UFW active'

echo '[*] Kernel hardening...'
cat > /etc/sysctl.d/99-fortress.conf << SYSCTL
net.ipv4.ip_forward = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.log_martians = 1
kernel.randomize_va_space = 2
fs.suid_dumpable = 0
SYSCTL
sysctl -p /etc/sysctl.d/99-fortress.conf > /dev/null
echo '[+] Kernel durci'

echo '[*] Activation fail2ban + auditd...'
systemctl enable --now fail2ban > /dev/null 2>&1
systemctl enable --now auditd > /dev/null 2>&1
echo '[+] Services actifs'

echo '[*] Permissions fichiers sensibles...'
chmod 600 /etc/shadow 2>/dev/null
chmod 644 /etc/passwd
chmod 700 /root
echo '[+] Permissions corrigees'

echo ''
echo "[*] Durcissement termine! Rapport: $REPORT"
