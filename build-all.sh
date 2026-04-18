#!/bin/bash

# AstraHost Automatic Build Script
# Digunakan untuk membangun semua image secara lokal di VPS

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}   ASTRAHOST - BUILD ALL IMAGES      ${NC}"
echo -e "${BLUE}=======================================${NC}"

# 1. Build Node.js Images
echo -e "${BLUE}Building Node.js images...${NC}"
for version in 18 20 22 24 25; do
    echo -e "Building node_$version..."
    docker build -t astrahost:node_$version -f nodejs/$version/Dockerfile .
done

# 2. Build Python Images
echo -e "${BLUE}Building Python images...${NC}"
for version in 3.11 3.12 3.13; do
    echo -e "Building python_$version..."
    docker build -t astrahost:python_$version -f python/$version/Dockerfile .
done

# 3. Build Bun Images
echo -e "${BLUE}Building Bun images...${NC}"
for version in 1.0 1.2 1.3 latest canary; do
    echo -e "Building bun_$version..."
    docker build -t astrahost:bun_$version -f bun/$version/Dockerfile .
done

# 4. Build Universal Images (Paling Overpower)
echo -e "${BLUE}Building Universal images (ini agak lama)...${NC}"
docker build -t astrahost:debian12_universal -f universal/debian/12/Dockerfile .
docker build -t astrahost:debian13_universal -f universal/debian/13/Dockerfile .
docker build -t astrahost:ubuntu22_universal -f universal/ubuntu/22.04/Dockerfile .
docker build -t astrahost:ubuntu24_universal -f universal/ubuntu/24.04/Dockerfile .
docker build -t astrahost:ubuntu25_universal -f universal/ubuntu/25.10/Dockerfile .

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}      SEMUA BUILD SELESAI!           ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "Sekarang Anda bisa menggunakan image tersebut di panel dengan nama:"
echo -e "- astrahost:ubuntu25_universal (Rekomendasi)"
echo -e "- astrahost:node_22"
echo -e "- dll."
