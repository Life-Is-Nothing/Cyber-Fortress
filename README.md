# Cyber-Fortress

> Script de durcissement automatique pour systemes Linux.

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnu-bash)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![Author](https://img.shields.io/badge/Author-ibramoha2-CC0000?style=flat-square)

## Usage
```bash
git clone https://github.com/ibramoha2/Cyber-Fortress
cd Cyber-Fortress
sudo bash fortress.sh
```

## Ce que fait le script
- Securise SSH (desactive root login, force les cles)
- Configure le firewall UFW
- Durcit le kernel via sysctl
- Installe fail2ban + auditd
- Corrige les permissions des fichiers sensibles
- Genere un rapport de durcissement

## Pre-requis
- Ubuntu / Debian 20.04+
- Acces root

**Auteur :** [@ibramoha2](https://github.com/ibramoha2) | Niger