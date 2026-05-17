#!/bin/bash
# ============================================================
#  AstraHost PM2 Startup Script
#  Dieksekusi oleh Pterodactyl panel saat server dinyalakan
#  Compatible dengan: astrahost:node_* images
# ============================================================

set -euo pipefail

# ── Color Codes ──────────────────────────────────────────────
RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'
CYAN='\e[1;36m'; MAGENTA='\e[1;35m'; RESET='\e[0m'
BOLD='\e[1m'; DIM='\e[2m'

INFO()  { echo -e "${CYAN}[INFO]${RESET}  $1"; }
OK()    { echo -e "${GREEN}[OK]${RESET}    $1"; }
WARN()  { echo -e "${YELLOW}[WARN]${RESET}  $1"; }
ERR()   { echo -e "${RED}[ERR]${RESET}   $1"; }
STEP()  { echo -e "${MAGENTA}[STEP]${RESET}  $1"; }
HR()    { echo -e "${DIM}──────────────────────────────────────────${RESET}"; }

# ── Banner ───────────────────────────────────────────────────
clear 2>/dev/null || true
echo ""
echo -e "${MAGENTA}${BOLD}"
echo "  ╔═══════════════════════════════════════════════════╗"
echo "  ║     AstraHost ⚡ PM2 Pro — Process Manager        ║"
echo "  ║     Powered by PM2 + Node.js                      ║"
echo "  ╚═══════════════════════════════════════════════════╝"
echo -e "${RESET}"

# ── Working Directory ─────────────────────────────────────────
cd /home/container || { ERR "Cannot cd /home/container"; exit 1; }

# ── Environment Setup ─────────────────────────────────────────
export TZ="${TZ:-Asia/Jakarta}"
export NODE_ENV="${NODE_ENV:-production}"
export PM2_HOME="/home/container/.pm2"
export PM2_SILENT=false
mkdir -p /home/container/.pm2 /home/container/logs

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2); exit}' || echo "127.0.0.1")
export INTERNAL_IP

HR
INFO "Timezone    : ${TZ}"
INFO "Node ENV    : ${NODE_ENV}"
INFO "Working Dir : $(pwd)"
INFO "Internal IP : ${INTERNAL_IP}"
HR

# ── PM2 Version Check ─────────────────────────────────────────
STEP "Checking PM2 installation..."
if ! command -v pm2 &>/dev/null; then
    WARN "PM2 not found globally. Installing PM2..."
    npm install -g pm2@latest --silent
fi
PM2_VER=$(pm2 --version 2>/dev/null || echo "unknown")
OK "PM2 v${PM2_VER} ready."

# ── XVFB (Headless Display) ───────────────────────────────────
if [ "${XVFB_ENABLE:-0}" = "1" ]; then
    STEP "Starting XVFB virtual display..."
    XVFB_DISPLAY="${XVFB_DISPLAY:-:99}"
    export DISPLAY="$XVFB_DISPLAY"
    if command -v Xvfb &>/dev/null; then
        nohup Xvfb "$XVFB_DISPLAY" -screen 0 "1920x1080x24" -ac +extension RANDR >/tmp/xvfb.log 2>&1 &
        sleep 1
        OK "XVFB started on display $XVFB_DISPLAY"
    else
        WARN "Xvfb binary not found. Skipping."
    fi
fi

# ── Puppeteer/Chromium Path ───────────────────────────────────
if [ -x /usr/bin/chromium ]; then
    export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
elif [ -x /usr/bin/google-chrome-stable ]; then
    export PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
fi

# ── Auto-Update via Git ───────────────────────────────────────
if [ "${AUTO_UPDATE:-0}" = "1" ] && [ -d .git ]; then
    STEP "AUTO_UPDATE enabled. Pulling latest changes..."
    git pull --rebase --autostash 2>&1 || WARN "git pull failed, continuing with current version."
    OK "Auto-update complete."
fi

# ── Extra npm Packages ────────────────────────────────────────
if [ -n "${NODE_PACKAGES:-}" ]; then
    STEP "Installing extra packages: ${NODE_PACKAGES}"
    npm install ${NODE_PACKAGES} --prefer-offline --silent || WARN "Some extra packages failed to install."
    OK "Extra packages installed."
fi

# ── Dependency Install ────────────────────────────────────────
if [ -f package.json ]; then
    if [ ! -d node_modules ] || [ package.json -nt node_modules/.package-lock.json 2>/dev/null ]; then
        STEP "Installing npm dependencies..."
        if [ "${NODE_ENV}" = "development" ]; then
            npm install --prefer-offline
        else
            npm install --production --prefer-offline
        fi
        OK "Dependencies installed."
    else
        INFO "node_modules up-to-date. Skipping install."
    fi
fi

# ── Log Rotation Setup ────────────────────────────────────────
MAX_LINES="${PM2_LOG_MAX_LINES:-5000}"
if [ "$MAX_LINES" -gt "0" ] 2>/dev/null; then
    STEP "Setting up log rotation (max ${MAX_LINES} lines per file)..."
    pm2 install pm2-logrotate --silent 2>/dev/null || true
    pm2 set pm2-logrotate:max_size 10M 2>/dev/null || true
    pm2 set pm2-logrotate:retain 3 2>/dev/null || true
    pm2 set pm2-logrotate:compress true 2>/dev/null || true
    OK "Log rotation configured."
fi

# ── Kill existing PM2 daemon (clean start) ────────────────────
pm2 kill 2>/dev/null || true
sleep 1

# ── Build PM2 Start Command ───────────────────────────────────
HR
STEP "Launching application with PM2..."
echo ""

APP_NAME="${PM2_APP_NAME:-bot}"
PM2_SCRIPT="${PM2_SCRIPT:-index.js}"
EXEC_MODE="${PM2_EXEC_MODE:-fork}"
INSTANCES="${PM2_INSTANCES:-1}"
MAX_MEM="${MAX_MEMORY:-512}M"
MAX_RESTARTS="${MAX_RESTARTS:-10}"
RESTART_DELAY="${RESTART_DELAY:-3000}"
MIN_UPTIME="${MIN_UPTIME:-5s}"
KILL_TIMEOUT="${KILL_TIMEOUT:-5000}"

# Cek apakah pakai ecosystem.config.js
USE_ECOSYSTEM="${USE_ECOSYSTEM:-1}"

if [ "$USE_ECOSYSTEM" = "1" ] && [ -f ecosystem.config.js ]; then
    INFO "Using ecosystem.config.js (advanced mode)"
    exec pm2-runtime start ecosystem.config.js \
        --env "${NODE_ENV}" \
        --no-daemon \
        2>&1

elif [ "$USE_ECOSYSTEM" = "1" ] && [ -f ecosystem.config.cjs ]; then
    INFO "Using ecosystem.config.cjs (advanced mode)"
    exec pm2-runtime start ecosystem.config.cjs \
        --env "${NODE_ENV}" \
        --no-daemon \
        2>&1

else
    INFO "Using direct script mode: ${PM2_SCRIPT}"
    INFO "App Name    : ${APP_NAME}"
    INFO "Exec Mode   : ${EXEC_MODE}"
    INFO "Instances   : ${INSTANCES}"
    INFO "Max Memory  : ${MAX_MEM}"
    INFO "Max Restart : ${MAX_RESTARTS}"
    INFO "Restart Del : ${RESTART_DELAY}ms"
    echo ""

    exec pm2-runtime start "${PM2_SCRIPT}" \
        --name "${APP_NAME}" \
        --no-daemon \
        --node-args "--max-old-space-size=512" \
        --env "NODE_ENV=${NODE_ENV}" \
        -i "${INSTANCES}" \
        --exec-mode "${EXEC_MODE}" \
        --max-memory-restart "${MAX_MEM}" \
        --max-restarts "${MAX_RESTARTS}" \
        --restart-delay "${RESTART_DELAY}" \
        --min-uptime "${MIN_UPTIME}" \
        --kill-timeout "${KILL_TIMEOUT}" \
        --log "./logs/pm2-out.log" \
        --error "./logs/pm2-err.log" \
        --log-date-format "YYYY-MM-DD HH:mm:ss" \
        --merge-logs \
        2>&1
fi
