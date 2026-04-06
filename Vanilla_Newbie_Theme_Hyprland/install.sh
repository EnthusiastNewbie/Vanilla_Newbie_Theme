#!/bin/bash

# ==============================================
# VANILLA NEWBIE HYPRLAND INSTALLER 
# ==============================================

# Colori per l'output
GREEN="\e[32m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${CYAN}Starting Installation of Vanilla Newbie Theme...${RESET}"

# 0. Installazione Dipendenze (Pacman)
echo -e "${MAGENTA}[*] Checking and installing dependencies...${RESET}"
DEPENDENCIES="hyprland hyprlock hyprpaper waybar wofi alacritty fastfetch starship sddm xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-kde-agent qt5ct qt6ct nwg-look btop pipewire wireplumber pipewire-audio pipewire-pulse pavucontrol network-manager-applet bluez bluez-utils blueman thunar thunar-volman tumbler gvfs gvfs-mtp thunar-archive-plugin file-roller wl-clipboard brightnessctl swappy grim slurp ttf-font-awesome otf-font-awesome ttf-jetbrains-mono-nerd xorg-xwayland mesa qt5-graphicaleffects qt5-quickcontrols2 qt5-svg qt6-declarative qt6-5compat qt5-wayland qt6-wayland nwg-look"

sudo pacman -S --needed --noconfirm $DEPENDENCIES

# 1. Crea le cartelle necessarie
echo -e "${MAGENTA}[*] Creating directories...${RESET}"
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/wofi
mkdir -p ~/.config/dunst
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/fastfetch
mkdir -p ~/.config/gtk-4.0
mkdir -p ~/.local/share/themes
mkdir -p ~/Pictures

# 2. Copia i Config files
echo -e "${GREEN}[*] Copying Dotfiles...${RESET}"
cp -r hypr/* ~/.config/hypr/ 2>/dev/null
cp -r waybar/* ~/.config/waybar/ 2>/dev/null
cp -r wofi/* ~/.config/wofi/ 2>/dev/null
cp -r dunst/* ~/.config/dunst/ 2>/dev/null
cp -r alacritty/* ~/.config/alacritty/ 2>/dev/null
cp -r fastfetch/* ~/.config/fastfetch/ 2>/dev/null
cp starship/starship.toml ~/.config/starship.toml 2>/dev/null

# 3. Copia il Wallpaper
echo -e "${GREEN}[*] Copying Wallpaper...${RESET}"
cp -r Pictures/* ~/Pictures/ 2>/dev/null

# 4. Installa il Tema GTK e crea Link GTK4
echo -e "${GREEN}[*] Installing GTK Theme (Vanilla_Newbie)...${RESET}"
cp -r Vanilla_Newbie ~/.local/share/themes/

echo -e "${CYAN}[*] Creating GTK4 symlinks for consistency...${RESET}"
ln -sf ~/.local/share/themes/Vanilla_Newbie/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -sf ~/.local/share/themes/Vanilla_Newbie/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css

# 5. Installa il Tema SDDM (Login Manager) 
if [ -d "Vanilla_Newbie_Theme_Sddm" ]; then
    echo -e ""
    echo -e "${RED}#############################################################${RESET}"
    echo -e "${YELLOW} ⚠️  ATTENZIONE: INSTALLAZIONE TEMA LOGIN (SDDM) RICHIESTA  ⚠️ ${RESET}"
    echo -e "${RED}#############################################################${RESET}"
    echo -e "${CYAN}Stiamo per installare il tema per la schermata di login (SDDM).${RESET}"
    echo -e "Per fare questo, dobbiamo copiare dei file nella cartella di sistema ${YELLOW}/usr/share/sddm/themes${RESET}"
    echo -e "e configurare il file ${YELLOW}/etc/sddm.conf${RESET}."
    echo -e "Questa operazione richiede i permessi di AMMINISTRATORE."
    echo -e "${RED}>>> Inserisci la tua password qui sotto per procedere: <<<${RESET}"
    echo -e ""
    
    # Copia del tema
    if [ -d "/usr/share/sddm/themes" ]; then
        sudo cp -r Vanilla_Newbie_Theme_Sddm /usr/share/sddm/themes/
        
        # Abilitazione servizio
        sudo systemctl enable sddm
        
        # Generazione automatica sddm.conf
        sudo bash -c 'cat > /etc/sddm.conf <<EOF
[General]
# Abilita il supporto per monitor ad alta risoluzione
EnableHiDPI=true
# Se vuoi il tastierino numerico attivo subito
Numlock=on

[Theme]
# Il nome della cartella in /usr/share/sddm/themes/
Current=Vanilla_Newbie_Theme_Sddm
# Usa il cursore standard di sistema
CursorTheme=Adwaita

[Users]
MaximumUid=60000
MinimumUid=1000

[Wayland]
EnableHiDPI=true
EOF'
        echo -e "${GREEN}✅ SDDM configurato e abilitato con successo!${RESET}"
    else
        echo -e "${RED}❌ Errore: Cartella SDDM non trovata. SDDM è installato?${RESET}"
    fi
fi

# 6. Permessi di esecuzione
echo -e "${GREEN}[*] Setting permissions...${RESET}"
chmod +x ~/.config/waybar/scripts/power-menu.sh 2>/dev/null
chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null

# 7. Aggiunta Fastfetch a .bashrc
if ! grep -q "fastfetch" ~/.bashrc; then
    echo -e "${MAGENTA}[*] Adding fastfetch to .bashrc...${RESET}"
    echo -e "\n# Launch Fastfetch\nfastfetch" >> ~/.bashrc
fi

# 8. Applicazione Settings GTK
echo -e "${CYAN}[*] Applying GTK Theme settings...${RESET}"
gsettings set org.gnome.desktop.interface gtk-theme "Vanilla_Newbie"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

echo -e "${CYAN}=========================================${RESET}"
echo -e "${GREEN} INSTALLATION COMPLETE! Please reboot your PC.${RESET}"
echo -e "${CYAN}=========================================${RESET}"
