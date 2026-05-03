#!/bin/bash

# ============================================================
#   PTERODACTYL FULL CLEANUP SCRIPT
#   Membersihkan: Panel, Wings, Nginx, PHP, MySQL, 
#                 Docker, Certbot, Redis, dan semua sisa file
#   Jalankan sebagai: sudo bash cleanup-vps.sh
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "============================================================"
echo "   🧹 PTERODACTYL FULL VPS CLEANUP SCRIPT"
echo "============================================================"
echo -e "${NC}"

# Cek apakah script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[ERROR] Script harus dijalankan sebagai root!${NC}"
  echo "Gunakan: sudo bash cleanup-vps.sh"
  exit 1
fi

echo -e "${YELLOW}[WARNING] Script ini akan MENGHAPUS PERMANEN semua komponen Pterodactyl!${NC}"
echo -e "${YELLOW}         Termasuk: Panel, Wings, Nginx, PHP, MySQL, Docker, Certbot, Redis${NC}"
echo ""
read -rp "Yakin ingin melanjutkan? Ketik 'HAPUS' untuk konfirmasi: " CONFIRM

if [ "$CONFIRM" != "HAPUS" ]; then
  echo -e "${RED}Dibatalkan.${NC}"
  exit 0
fi

echo ""
echo -e "${CYAN}[1/12] Menghentikan semua service...${NC}"
# ── Stop services
systemctl stop wings 2>/dev/null || true
systemctl stop pterodactyl 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true
systemctl stop php8.3-fpm 2>/dev/null || true
systemctl stop php8.2-fpm 2>/dev/null || true
systemctl stop php8.1-fpm 2>/dev/null || true
systemctl stop php8.0-fpm 2>/dev/null || true
systemctl stop php7.4-fpm 2>/dev/null || true
systemctl stop mysql 2>/dev/null || true
systemctl stop mariadb 2>/dev/null || true
systemctl stop redis-server 2>/dev/null || true
systemctl stop redis 2>/dev/null || true
echo -e "${GREEN}  ✓ Service dihentikan${NC}"

echo -e "${CYAN}[2/12] Menghapus Wings daemon...${NC}"
# ── Hapus Wings
systemctl disable wings 2>/dev/null || true
rm -f /etc/systemd/system/wings.service
rm -f /usr/local/bin/wings
rm -rf /etc/pterodactyl
rm -rf /var/log/pterodactyl
rm -rf /tmp/pterodactyl-installer.log
rm -f /var/log/pterodactyl-installer.log
echo -e "${GREEN}  ✓ Wings dihapus${NC}"

echo -e "${CYAN}[3/12] Menghapus Panel Pterodactyl...${NC}"
# ── Hapus Panel
rm -rf /var/www/pterodactyl
rm -rf /var/www/html/pterodactyl
# Hapus semua folder yang kemungkinan dipakai panel
find /var/www -maxdepth 2 -name "pterodactyl*" -exec rm -rf {} + 2>/dev/null || true
echo -e "${GREEN}  ✓ Panel dihapus${NC}"

echo -e "${CYAN}[4/12] Menghapus Docker dan semua container/image...${NC}"
# ── Hapus Docker
if command -v docker &>/dev/null; then
  docker stop $(docker ps -aq) 2>/dev/null || true
  docker rm -f $(docker ps -aq) 2>/dev/null || true
  docker rmi -f $(docker images -q) 2>/dev/null || true
  docker system prune -af --volumes 2>/dev/null || true
fi
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin 2>/dev/null || true
apt-get purge -y docker.io docker-compose 2>/dev/null || true
rm -rf /var/lib/docker
rm -rf /etc/docker
rm -f /etc/apt/sources.list.d/docker.list
rm -f /usr/share/keyrings/docker-archive-keyring.gpg
rm -f /etc/apt/keyrings/docker.gpg
echo -e "${GREEN}  ✓ Docker dihapus${NC}"

echo -e "${CYAN}[5/12] Menghapus Nginx / Apache...${NC}"
# ── Hapus Nginx
apt-get purge -y nginx nginx-common nginx-full nginx-extras 2>/dev/null || true
rm -rf /etc/nginx
rm -rf /var/log/nginx
rm -f /etc/apt/sources.list.d/nginx.list

# ── Hapus Apache
apt-get purge -y apache2 apache2-utils apache2-bin 2>/dev/null || true
rm -rf /etc/apache2
rm -rf /var/log/apache2
echo -e "${GREEN}  ✓ Nginx/Apache dihapus${NC}"

echo -e "${CYAN}[6/12] Menghapus PHP (semua versi)...${NC}"
# ── Hapus semua versi PHP
for ver in 7.4 8.0 8.1 8.2 8.3; do
  apt-get purge -y php${ver} php${ver}-* 2>/dev/null || true
done
apt-get purge -y php php-* php-common 2>/dev/null || true
rm -rf /etc/php
rm -rf /var/lib/php
# Hapus repo PHP (ondrej)
rm -f /etc/apt/sources.list.d/php.list
rm -f /etc/apt/sources.list.d/ondrej-*.list
rm -f /usr/share/keyrings/php-archive-keyring.gpg
echo -e "${GREEN}  ✓ PHP dihapus${NC}"

echo -e "${CYAN}[7/12] Menghapus MySQL / MariaDB...${NC}"
# ── Hapus MySQL/MariaDB beserta semua datanya
DEBIAN_FRONTEND=noninteractive apt-get purge -y mysql-server mysql-client mysql-common mysql-server-core-* 2>/dev/null || true
DEBIAN_FRONTEND=noninteractive apt-get purge -y mariadb-server mariadb-client mariadb-common 2>/dev/null || true
rm -rf /var/lib/mysql
rm -rf /var/lib/mysql-files
rm -rf /var/lib/mysql-keyring
rm -rf /etc/mysql
rm -rf /var/log/mysql
rm -f /etc/apt/sources.list.d/mariadb.list
rm -f /usr/share/keyrings/mariadb-archive-keyring.gpg
echo -e "${GREEN}  ✓ MySQL/MariaDB dan semua database dihapus${NC}"

echo -e "${CYAN}[8/12] Menghapus Redis...${NC}"
apt-get purge -y redis-server redis redis-tools 2>/dev/null || true
rm -rf /etc/redis
rm -rf /var/lib/redis
rm -rf /var/log/redis
echo -e "${GREEN}  ✓ Redis dihapus${NC}"

echo -e "${CYAN}[9/12] Menghapus Certbot dan sertifikat SSL...${NC}"
# ── Hapus Certbot (semua metode instalasi)
# Snap
if command -v snap &>/dev/null; then
  snap remove --purge certbot 2>/dev/null || true
fi
# APT
apt-get purge -y certbot python3-certbot python3-certbot-nginx python3-certbot-apache 2>/dev/null || true
# PIP / standalone
pip3 uninstall certbot -y 2>/dev/null || true
# Hapus semua sertifikat Let's Encrypt
rm -rf /etc/letsencrypt
rm -rf /var/lib/letsencrypt
rm -rf /var/log/letsencrypt
rm -f /usr/local/bin/certbot
rm -f /usr/bin/certbot
# Hapus cron certbot
rm -f /etc/cron.d/certbot
rm -f /etc/cron.weekly/certbot
# Hapus systemd timer certbot
systemctl disable certbot.timer 2>/dev/null || true
systemctl stop certbot.timer 2>/dev/null || true
rm -f /lib/systemd/system/certbot.service
rm -f /lib/systemd/system/certbot.timer
echo -e "${GREEN}  ✓ Certbot dan semua sertifikat SSL dihapus${NC}"

echo -e "${CYAN}[10/12] Menghapus Composer...${NC}"
rm -f /usr/local/bin/composer
rm -f /usr/bin/composer
rm -rf /root/.composer
rm -rf /home/*/.composer
echo -e "${GREEN}  ✓ Composer dihapus${NC}"

echo -e "${CYAN}[11/12] Membersihkan file sisa dan cache...${NC}"
# ── File sisa installer
rm -f /tmp/lib.sh
rm -f /tmp/installer.sh
rm -rf /tmp/pterodactyl*
# ── Crontab pterodactyl (jika ada)
crontab -l 2>/dev/null | grep -v pterodactyl | crontab - 2>/dev/null || true
# ── Reload systemd
systemctl daemon-reload
# ── APT cleanup
apt-get autoremove -y 2>/dev/null || true
apt-get autoclean -y 2>/dev/null || true
apt-get clean 2>/dev/null || true
echo -e "${GREEN}  ✓ File sisa dibersihkan${NC}"

echo -e "${CYAN}[12/12] Verifikasi pembersihan...${NC}"
echo ""
echo -e "${YELLOW}--- Cek sisa proses ---${NC}"
LEFTOVER=false
command -v wings &>/dev/null && echo -e "${RED}  ✗ wings masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ wings tidak ditemukan${NC}"
command -v nginx &>/dev/null && echo -e "${RED}  ✗ nginx masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ nginx tidak ditemukan${NC}"
command -v php &>/dev/null && echo -e "${RED}  ✗ php masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ php tidak ditemukan${NC}"
command -v mysql &>/dev/null && echo -e "${RED}  ✗ mysql masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ mysql tidak ditemukan${NC}"
command -v docker &>/dev/null && echo -e "${RED}  ✗ docker masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ docker tidak ditemukan${NC}"
command -v certbot &>/dev/null && echo -e "${RED}  ✗ certbot masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ certbot tidak ditemukan${NC}"
[ -d /var/www/pterodactyl ] && echo -e "${RED}  ✗ folder panel masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ folder panel tidak ditemukan${NC}"
[ -d /etc/pterodactyl ] && echo -e "${RED}  ✗ folder config wings masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ folder config wings tidak ditemukan${NC}"
[ -d /etc/letsencrypt ] && echo -e "${RED}  ✗ folder certbot masih ada${NC}" && LEFTOVER=true || echo -e "${GREEN}  ✓ folder certbot tidak ditemukan${NC}"

echo ""
echo "============================================================"
if [ "$LEFTOVER" = true ]; then
  echo -e "${YELLOW}  ⚠  Ada beberapa sisa yang perlu dicek manual di atas.${NC}"
else
  echo -e "${GREEN}  ✅ VPS BERHASIL DIBERSIHKAN SEPENUHNYA!${NC}"
fi
echo "============================================================"
echo ""
echo -e "${CYAN}Sekarang kamu bisa install ulang Pterodactyl dengan:${NC}"
echo -e "  ${GREEN}bash <(curl -s https://pterodactyl-installer.se)${NC}"
echo ""
