#!/bin/sh

echo "[WSDB] For more information please see https://github.com/whiteout-project/bot"

# Preload our dummy affinity library
export LD_PRELOAD=/usr/lib/dummy_affinity.so

# Set all thread control variables
export OMP_NUM_THREADS=1
export OMP_WAIT_POLICY=PASSIVE
export KMP_AFFINITY=disabled
export KMP_BLOCKTIME=0
export TF_NUM_INTEROP_THREADS=1
export TF_NUM_INTRAOP_THREADS=1
export ORT_DISABLE_THREAD_AFFINITY=1
export ORT_GLOBAL_DISABLE_AFFINITY=1
export ORT_LOG_LEVEL=3

cd /app

if [ ! -n "${DISCORD_BOT_TOKEN}" ]; then
    echo "please set DISCORD_BOT_TOKEN"
    exit
fi

if [ -n "${DISCORD_BOT_TOKEN}" ]; then
    echo "${DISCORD_BOT_TOKEN}" > bot_token.txt
fi

python main.py --autoupdate --no-venv
