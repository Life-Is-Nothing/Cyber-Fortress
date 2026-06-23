#!/bin/bash
# Security Check rapide - ibramoha2
echo "=== Security Check - $(date) ==="
echo ''
echo '[SSH] PermitRootLogin:'
grep '^PermitRootLogin' /etc/ssh/sshd_config 2>/dev/null || echo '  Non configure'
echo ''
echo '[UFW] Status:'
ufw status 2>/dev/null | head -3
echo ''
echo "[fail2ban]: $(systemctl is-active fail2ban 2>/dev/null)"
echo "[auditd]: $(systemctl is-active auditd 2>/dev/null)"
echo ''
echo '[SUID] Fichiers suspects:'
find /tmp /home /var -perm /4000 -type f 2>/dev/null || echo '  Aucun'
