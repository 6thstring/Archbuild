#!/usr/bin/env bash
# Enable extensions
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com
which pamac &>/dev/null && gnome-extensions enable pamac-updates@manjaro.org
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com # Enable user-theme extension for shell theming

# Apply theming
gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-purple-dark"
gsettings set org.gnome.shell.extensions.user-theme name "Orchis-pink-dark"

# Enable fractional scaling in wayland
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

git clone https://github.com/Zackptg5/gnome-dash-fix
chmod +x gnome-dash-fix/interactive.py
./gnome-dash-fix/interactive.py


echo "Set font to 'MesloLGNS NF Regular' in Gnome Terminal before first launching it!"
echo "See this script for list of 3rd party extensions I use"

# Gnome Shell Extensions to Install After booting:
# AppIndicator
# Caffeine
# Dash to Dock
# GSConnect
# Sounds and Input Device Chooser
# Improved OSK - only needed if you have a touchscreen