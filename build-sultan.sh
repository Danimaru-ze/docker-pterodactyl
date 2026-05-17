#!/bin/bash

# Jagoan Project - Sultan Build Script
# Membangun koleksi Node.js LTS + Universal Debian 12

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}    JAGOAN PROJECT - SULTAN BUILD      ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Aktifkan BuildKit untuk kecepatan Sultan
export DOCKER_BUILDKIT=1

REGISTRY="${REGISTRY:-jagoanproject}"

# 1. Build Node.js LTS
echo -e "\n${YELLOW}[1/2] Building Node.js LTS versions (18, 20, 22, 24)...${NC}"
for version in 18 20 22 24; do
    echo -e "--- Building node_${version} ---"
    docker build -t "${REGISTRY}:node_${version}" -f nodejs/$version/Dockerfile . \
        && echo -e "${GREEN}✓ node_${version} selesai${NC}" \
        || echo -e "${RED}✗ node_${version} GAGAL${NC}"
done

# 2. Build Universal Debian 12
echo -e "\n${YELLOW}[2/2] Building Universal Debian 12...${NC}"
docker build -t "${REGISTRY}:debian12_universal" -f universal/debian/12/Dockerfile . \
    && echo -e "${GREEN}✓ debian12_universal selesai${NC}" \
    || echo -e "${RED}✗ debian12_universal GAGAL${NC}"

echo -e "\n${BLUE}=======================================${NC}"
echo -e "${GREEN}      SULTAN BUILD SELESAI!          ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "Silakan gunakan image ini di Pterodactyl Panel:"
echo -e "  ${GREEN}Node.js:${NC}  ${REGISTRY}:node_18 / node_20 / node_22 / node_24"
echo -e "  ${GREEN}Debian:${NC}   ${REGISTRY}:debian12_universal  (Direkomendasikan)"
echo -e ""
echo -e "${YELLOW}CATATAN:${NC} Jangan lupa Reinstall Server di panel setelah ganti image!"
