#!/bin/bash

# AstraHost Sultan Build Script
# Digunakan untuk membangun koleksi Node.js lengkap (18-25) dan Universal Ubuntu 24

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}      ASTRAHOST - SULTAN BUILD         ${NC}"
echo -e "${BLUE}=======================================${NC}"

# 1. Build Node.js Images (18-25)
echo -e "${YELLOW}Building ALL Node.js images (18 to 25)...${NC}"
for version in 18 19 20 21 22 23 24 25; do
    echo -e "--- Building node_$version ---"
    docker build -t astrahost:node_$version -f nodejs/$version/Dockerfile .
done

# 2. Build Universal Ubuntu 24 (The Overpower One)
echo -e "${YELLOW}Building Universal Ubuntu 24 (Ini akan memakan waktu)...${NC}"
docker build -t astrahost:ubuntu24_universal -f universal/ubuntu/24.04/Dockerfile .

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}      SULTAN BUILD SELESAI!          ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "Silakan gunakan image ini di Pterodactyl Panel:"
echo -e "- astrahost:node_18 s/d astrahost:node_25"
echo -e "- astrahost:ubuntu24_universal (Overpower)"
echo -e ""
echo -e "${YELLOW}CATATAN:${NC} Jangan lupa Reinstall Server di panel setelah ganti image!"
