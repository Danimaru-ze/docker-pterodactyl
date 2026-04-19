#!/bin/bash
cd /home/container || exit 1

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}')
export INTERNAL_IP

if [ -x /usr/local/bin/astrahost-banner ]; then
    /usr/local/bin/astrahost-banner
fi

STARTUP=${STARTUP:-npm start}

printf "\033[1m\033[33m%s@astrahost~ \033[0m%s\n" "$(whoami)" "$STARTUP"
eval ${STARTUP}
