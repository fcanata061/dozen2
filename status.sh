#!/bin/bash

# Fontes
FONT="-*-monospace-*-r-*-*-14-*-*-*-*-*-*-*"
ICON_FONT="Symbols Nerd Font:size=12"

# Cores
FG="#eeeeee"
BG="#1c1c1c"
HL="#ffb52a"
OK="#98c379"
WARN="#e5c07b"
ERR="#e06c75"

# ========= MÓDULOS ========= #

cpu() {
    usage=$(grep 'cpu ' /proc/stat | awk '{u=($2+$4)*100/($2+$4+$5)} END {print int(u)}')
    echo "^ca(1, xterm -e htop)^fg($OK) $usage%^ca()"
}

mem() {
    free -h | awk '/Mem:/ {print "^ca(1, xterm -e htop)^fg('"$WARN"') "$3"/"$2"^ca()"}'
}

net() {
    RX=$(cat /sys/class/net/w*/statistics/rx_bytes | awk '{s+=$1} END {print s}')
    TX=$(cat /sys/class/net/w*/statistics/tx_bytes | awk '{s+=$1} END {print s}')
    sleep 1
    RX2=$(cat /sys/class/net/w*/statistics/rx_bytes | awk '{s+=$1} END {print s}')
    TX2=$(cat /sys/class/net/w*/statistics/tx_bytes | awk '{s+=$1} END {print s}')
    UP=$(( (TX2 - TX) / 1024 ))
    DOWN=$(( (RX2 - RX) / 1024 ))
    echo "^fg($HL) $UP KB/s ^fg($HL) $DOWN KB/s"
}

temp() {
    t_cpu=$(sensors | awk '/^Package id 0:/ {print int($4)}')
    echo "^fg($ERR) ${t_cpu}°C"
}

vol() {
    level=$(amixer get Master | awk -F'[][]' 'END{ print $2 }')
    mute=$(amixer get Master | grep -q '\[off\]' && echo "🔇" || echo "")
    echo "^ca(1, amixer set Master toggle)^ca(4, amixer set Master 5%+)^ca(5, amixer set Master 5%-)^fg($OK)$mute $level^ca()^ca()^ca()"
}

updates() {
    upd=$(check-lfs-updates 2>/dev/null | wc -l)
    if [ "$upd" -gt 0 ]; then
        echo "^ca(1, xterm -e sudo lfs-update)^fg($WARN) $upd^ca()"
    else
        echo "^fg($OK) 0"
    fi
}

clock() {
    echo "^ca(1, ~/.config/dzen2/showcal.sh)^fg($FG) $(date '+%d/%m') ^fg($HL) $(date '+%H:%M')^ca()"
}

workspaces() {
    cur=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')
    tot=$(xprop -root _NET_NUMBER_OF_DESKTOPS | awk '{print $3}')
    out=""
    for i in $(seq 0 $((tot-1))); do
        if [ "$i" -eq "$cur" ]; then
            out="$out ^ca(1, wmctrl -s $i)^fg($HL)[$i]^ca() "
        else
            out="$out ^ca(1, wmctrl -s $i)^fg($FG) $i ^ca() "
        fi
    done
    echo "$out"
}

# ========= LOOP ========= #
while true; do
    echo "$(workspaces) | $(cpu) | $(mem) | $(net) | $(temp) | $(vol) | $(updates) | $(clock)"
    sleep 2
done | dzen2 -x 0 -y 0 -h 24 -w 1920 -ta l -fg "$FG" -bg "$BG" -fn "$FONT"
