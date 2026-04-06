#!/bin/bash
# =================================================================
#  Vanilla_Newbie - Dotfiles & Theme Installer 
# =================================================================

# --- 1. CONFIGURAZIONE E PERCORSI ---
THEME_DIR="$(dirname "$(readlink -f "$0")")"
THEME_NAME="Vanilla_Newbie"

# Colori per un output leggibile
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funzione gestione errori
handle_error() {
    if [ $1 -ne 0 ]; then
        echo -e "\n${RED}[ERRORE CRITICO]${NC} Fallito: $2"
        exit 1
    fi
}

# --- 2. LOGICA DI INSTALLAZIONE (OTTIMIZZATA PER DEBIAN 13) ---
check_and_install_dependencies() {
    echo -e "${CYAN}[*] Inizio controllo dipendenze...${NC}"
    
    local deps=(
        "labwc" "xwayland" "alacritty" "wofi" "waybar" "swaybg" 
        "xdg-user-dirs" "xdg-utils" "xdg-desktop-portal" "xdg-desktop-portal-wlr" 
        "qtwayland5" "qt6-wayland-dev" "thunar" "thunar-volman" "gvfs" 
        "gvfs-backends" "udisks2" "thunar-archive-plugin" "pipewire" 
        "wireplumber" "pavucontrol" "pamixer" "brightnessctl" "network-manager" 
        "network-manager-gnome" "bluez" "blueman" "lxpolkit" "fonts-noto" 
        "fonts-font-awesome" "mako-notifier" "grim" "slurp" "build-essential" "nwg-look" "gnome-text-editor" "git" "screenfetch"
    )

    echo -e "${MAGENTA}[INFO]${NC} Aggiornamento dei repository..."
    sudo apt update

    local to_install=()

    # Verifichiamo quali pacchetti mancano effettivamente
    for dep in "${deps[@]}"; do
        if dpkg -s "$dep" >/dev/null 2>&1; then
            echo -e "${GREEN}[OK]${NC} $dep è già presente."
        else
            to_install+=("$dep")
        fi
    done

    # Installazione in blocco unico 
    if [ ${#to_install[@]} -ne 0 ]; then
        echo -e "${CYAN}[*] Installazione di: ${to_install[*]}...${NC}"
        sudo apt install -y "${to_install[@]}"
        
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}[ATTENZIONE]${NC} Qualcosa è andato storto durante l'installazione dei pacchetti."
        else
            echo -e "${GREEN}[OK]${NC} Dipendenze installate correttamente."
        fi
    else
        echo -e "${GREEN}[OK]${NC} Tutte le dipendenze sono già soddisfatte."
    fi
}

echo -e "${MAGENTA}====================================================${NC}"
echo -e "${MAGENTA}--- 🌑 Installazione Vanilla_Newbie Dotfiles ---${NC}"
echo -e "${MAGENTA}====================================================${NC}"

# Avvio installazione
check_and_install_dependencies

# --- 3. PREPARAZIONE DIRECTORY ---
echo -e "${CYAN}[*] Creazione cartelle...${NC}"
mkdir -p ~/.config/{labwc,waybar,wofi,alacritty,gtk-3.0,gtk-4.0}
mkdir -p ~/.local/share/themes
mkdir -p ~/Pictures
handle_error $? "Creazione cartelle"

# --- 4. INSTALLAZIONE TEMA GTK ---
echo -e "${CYAN}[*] Installazione tema '$THEME_NAME'...${NC}"
if [ -d "$THEME_DIR/$THEME_NAME" ]; then
    rm -rf ~/.local/share/themes/$THEME_NAME
    cp -r "$THEME_DIR/$THEME_NAME" ~/.local/share/themes/
    handle_error $? "Copia cartella Tema"
else
    echo -e "${RED}[ERRORE CRITICO]${NC} Cartella del tema non trovata! Senza questa il setup non ha senso. Esco."
    exit 1
fi

# --- 5. COPIA DOTFILES ---
echo -e "${CYAN}[*] Copia dei file di configurazione...${NC}"
cp -r "$THEME_DIR/labwc/"* ~/.config/labwc/ || echo -e "${YELLOW}[AVVISO]${NC} File LabWC non trovati"
cp -r "$THEME_DIR/waybar/"* ~/.config/waybar/ || echo -e "${YELLOW}[AVVISO]${NC} File Waybar non trovati"
cp -r "$THEME_DIR/wofi/"* ~/.config/wofi/ || echo -e "${YELLOW}[AVVISO]${NC} File Wofi non trovati"
cp "$THEME_DIR/alacritty/alacritty.toml" ~/.config/alacritty/ || echo -e "${YELLOW}[AVVISO]${NC} Config Alacritty non trovata"

# --- 6. LINK GTK & WALLPAPER ---
echo -e "${CYAN}[*] Finalizzazione estetica...${NC}"
ln -sf ~/.local/share/themes/$THEME_NAME/gtk-3.0/gtk.css ~/.config/gtk-3.0/gtk.css
ln -sf ~/.local/share/themes/$THEME_NAME/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -sf ~/.local/share/themes/$THEME_NAME/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css

if [ -f "$THEME_DIR/wallpaper.png" ]; then
    cp "$THEME_DIR/wallpaper.png" ~/Pictures/vanilla_wallpaper.png
fi

# --- 7. SETTINGS E BASHRC ---
chmod +x ~/.config/labwc/autostart 2>/dev/null
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

if ! grep -q "screenfetch" ~/.bashrc; then
    echo -e "\n# Vanilla Newbie Welcome\nscreenfetch" >> ~/.bashrc
fi

# --- 8. CONCLUSIONE ---
echo -e "${CYAN}------------------------------------------------${NC}"
if command -v labwc >/dev/null 2>&1; then
    labwc --reconfigure 2>/dev/null
    echo -e "${CYAN}[INFO]${NC} LabWC ricaricato."
fi

echo -e "${GREEN}--- ✅ SETUP COMPLETATO! ---${NC}"
echo -e "${YELLOW}[NOTA]${NC} Riavvia il sistema per applicare tutte le modifiche e lancia la sessione col comando labwc"
echo -e "${CYAN}------------------------------------------------${NC}"
