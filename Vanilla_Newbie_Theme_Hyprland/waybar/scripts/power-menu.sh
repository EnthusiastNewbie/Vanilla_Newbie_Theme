#!/bin/bash

# Definisci le opzioni
shutdown="  Spegni"
reboot="  Riavvia"
logout="  Logout"
lock="  Blocca"

# Mostra il menu con Wofi
selected_option=$(echo -e "$lock\n$logout\n$reboot\n$shutdown" | wofi --dmenu --width 350 --height 350 --cache-file /dev/null --prompt "Power Menu")

# Esegui il comando in base alla scelta
case $selected_option in
    "$shutdown")
        systemctl poweroff
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$logout")
        hyprctl dispatch exit
        ;;
    "$lock")
        # Se usi hyprlock, altrimenti togli questa opzione
        pidof hyprlock || hyprlock
        ;;
esac
