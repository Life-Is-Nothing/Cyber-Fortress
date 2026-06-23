#!/bin/bash
# ============================================================
# Cyber-Fortress — Linux Security Monitoring & Hardening
# Author: Mohamed Adoungouss Ibrahim (@ibramoha2)
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

SCORE=0; TOTAL=0

banner() {
echo -e "${RED}"
cat << 'BANNER'
   ___      _               _____         _                    
  / __\   _| |__   ___ _ __|  ___|__  _ __| |_ _ __ ___  ___ ___ 
 / /| | | | '_ \ / _ \ '__| |_ / _ \| '__| __| '__/ _ \/ __/ __|
/ /_| |_| | |_) |  __/ |  |  _| (_) | |  | |_| | |  __/\__ \__ \
\____\__, |_.__/ \___|_|  |_|  \___/|_|   \__|_|  \___||___/___/
     |___/                                Mohamed Adoungouss Ibrahim
BANNER
echo -e "${NC}"
}

check() {
    local name="$1"; local cmd="$2"; local ok_msg="$3"; local fail_msg="$4"
    TOTAL=$((TOTAL+1))
    if eval "$cmd" &>/dev/null; then
        echo -e "  ${GREEN}[✅ PASS]${NC} $name — $ok_msg"
        SCORE=$((SCORE+1))
    else
        echo -e "  ${RED}[❌ FAIL]${NC} $name — $fail_msg"
    fi
}

check_services() {
    echo -e "\n${CYAN}${BOLD}[🔒 SERVICES DE SÉCURITÉ]${NC}"
    check "UFW Firewall"   "systemctl is-active ufw | grep -q active"     "Actif" "Inactif — sudo ufw enable"
    check "Fail2ban"       "systemctl is-active fail2ban | grep -q active" "Actif" "Inactif — sudo systemctl start fail2ban"
    check "CrowdSec"       "systemctl is-active crowdsec | grep -q active" "Actif" "Inactif"
    check "SSH"            "systemctl is-active ssh | grep -q active"      "Actif" "SSH inactif"
    check "Auditd"         "systemctl is-active auditd | grep -q active"   "Actif" "Inactif — sudo systemctl start auditd"
    check "AppArmor"       "aa-status 2>/dev/null | grep -q profiles"      "Actif" "Inactif"
}

check_ssh() {
    echo -e "\n${CYAN}${BOLD}[🔑 CONFIGURATION SSH]${NC}"
    local cf="/etc/ssh/sshd_config"
    check "PermitRootLogin désactivé" "grep -q '^PermitRootLogin no' $cf"   "OK" "Root login autorisé"
    check "Password auth désactivé"   "grep -q '^PasswordAuthentication no' $cf" "Clés uniquement" "Passwords autorisés"
    check "Port SSH non-standard"     "grep -q '^Port' $cf && ! grep -q '^Port 22$' $cf" "Port personnalisé" "Port 22 par défaut"
}

check_network() {
    echo -e "\n${CYAN}${BOLD}[🌐 RÉSEAU]${NC}"
    local listening=$(ss -tlnp 2>/dev/null | grep LISTEN | wc -l)
    echo -e "  ${BLUE}[INFO]${NC} Ports en écoute : $listening"
    check "IPv6 désactivé (optionnel)" "grep -q 'net.ipv6.conf.all.disable_ipv6 = 1' /etc/sysctl.conf" "IPv6 off" "IPv6 actif"
}

check_updates() {
    echo -e "\n${CYAN}${BOLD}[📦 MISES À JOUR]${NC}"
    check "Unattended-upgrades" "dpkg -l unattended-upgrades 2>/dev/null | grep -q '^ii'" "Installé" "Non installé"
}

check_logs() {
    echo -e "\n${CYAN}${BOLD}[📋 LOGS & MONITORING]${NC}"
    local failed=$(grep -c 'Failed password' /var/log/auth.log 2>/dev/null || echo 0)
    echo -e "  ${YELLOW}[INFO]${NC} Tentatives SSH échouées : $failed"
    local banned=$(fail2ban-client status sshd 2>/dev/null | grep 'Banned IP' | awk '{print $NF}')
    echo -e "  ${YELLOW}[INFO]${NC} IPs bannies (fail2ban/sshd) : ${banned:-0}"
}

report() {
    echo -e "\n${BOLD}════════════════════════════════════════${NC}"
    local pct=$((SCORE*100/TOTAL))
    if [ $pct -ge 80 ]; then
        echo -e "  ${GREEN}Score de sécurité : $SCORE/$TOTAL ($pct%) — EXCELLENT ✅${NC}"
    elif [ $pct -ge 60 ]; then
        echo -e "  ${YELLOW}Score de sécurité : $SCORE/$TOTAL ($pct%) — MOYEN ⚠️${NC}"
    else
        echo -e "  ${RED}Score de sécurité : $SCORE/$TOTAL ($pct%) — FAIBLE ❌${NC}"
    fi
    echo -e "${BOLD}════════════════════════════════════════${NC}\n"
}

banner
check_services
check_ssh
check_network
check_updates
check_logs
report
