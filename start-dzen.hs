#!/bin/bash

# Mata instâncias antigas
pkill -x dzen2
pkill -f status.sh

# Aguarda encerrar
sleep 0.5

# Caminho para o script de status
STATUS_SCRIPT="$HOME/.config/dzen2/status.sh"

# Inicia em background
"$STATUS_SCRIPT" &

echo "Dzen iniciado!"
