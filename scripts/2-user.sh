#!/usr/bin/env bash
echo -ne "
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: Archbuild
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/Archbuild/config/setup.conf

cd ~
mkdir "/home/$USERNAME/.cache"
touch "/home/$USERNAME/.cache/zshhistory"
git clone "https://github.com/ChrisTitusTech/zsh"
# Zsh doesn't read inputrc and so some keys like 'del' won't work right. Add keybindings
echo "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)" >> zsh/.zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
ln -s ~/zsh/.zshrc ~/.zshrc
sudo chsh -s $(which zsh) $(whoami) 
# Change editor to nano
sed -i "s/EDITOR=.*/EDITOR=nano/" zsh/.zshrc
sed -i "s/EDITOR=.*/EDITOR=nano/" zsh/aliasrc

if [[ $DESKTOP_ENV == "kde" && $INSTALL_TYPE == "FULL" ]]; then
  sed -i "s/plasma-desktop/plasma/" ~/Archbuild/pkg-files/${DESKTOP_ENV}.txt
fi
sed -n '/'$INSTALL_TYPE'/q;p' ~/Archbuild/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done

# Add Chaotic AUR
echo "Adding Chaotic AUR"
sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC880C036
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo bash -c "echo -e \"[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\" >> /etc/pacman.conf"
sudo pacman -Sy

if [[ -f ~/Archbuild/pkg-files/${DESKTOP_ENV}-chaoticaur.txt ]]; then
  sed -n '/'$INSTALL_TYPE'/q;p' ~/Archbuild/pkg-files/${DESKTOP_ENV}-chaoticaur.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
    then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    sudo pacman -S --noconfirm --needed ${line}
  done
fi

sed -n '/'$INSTALL_TYPE'/q;p' $HOME/Archbuild/pkg-files/chaoticaur-pkgs.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done

if [[ ! $AUR_HELPER == none ]]; then
  AUR_HELPER_ORIG=$AUR_HELPER
  if [[ $AUR_HELPER == "pamac-"* ]]; then
    sudo pacman -Rdd --noconfirm archlinux-appstream-data
    sudo pacman -S --noconfirm archlinux-appstream-data-pamac # Replace default with pamac
    sudo pacman -S yay --noconfirm --needed # Use yay temporarily - pamac doesn't work right during install
    AUR_HELPER=yay
  fi
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER_ORIG.git"
  cd ~/$AUR_HELPER_ORIG
  makepkg -si --noconfirm
  cd ~
  rm -rf ~/$AUR_HELPER_ORIG
  # sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # stop the script and move on, not installing any more packages below that line

  sed -n '/'$INSTALL_TYPE'/q;p' ~/Archbuild/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
  sudo ln -sf /usr/share/plymouth/themes/arch-breeze/logo_symb_blue.png /usr/share/plymouth/themes/arch-breeze/logo.png

  # Add advcpmv alias
  sed -i -e "s/alias cp=.*/alias cp='advcp -g'/" -e "s/alias mv=.*/alias mv='advmv -g'/" ~/zsh/aliasrc
fi

export PATH=$PATH:~/.local/bin

# Theming DE if user chose FULL installation
if [[ $INSTALL_TYPE == "FULL" ]]; then
  if [[ $DESKTOP_ENV == "kde" ]]; then
    sudo ln -sf /usr/share/plymouth/themes/arch-breeze/logo_symb_white.png /usr/share/plymouth/themes/arch-breeze/logo.png
    cp -r ~/ArchTitus/configs/.config/* ~/.config/
    pip install konsave
    konsave -i ~/Archbuild/config/kde.knsv
    sleep 1
    konsave -a kde
  elif [[ $DESKTOP_ENV == "openbox" ]]; then
    cd ~
    git clone https://github.com/stojshic/dotfiles-openbox
    ./dotfiles-openbox/install-titus.sh
  fi
fi

[ -z $AUR_HELPER_ORIG ] || { AUR_HELPER=$AUR_HELPER_ORIG; sudo pacman -Rs --noconfirm yay; }

# Get rid of all the extra application entries from zam-plugins and mda.lv2
mkdir -p $HOME/.local/share/applications
for i in /usr/share/applications/in.lsp_plug* /usr/share/applications/com.zamaudio*; do
  sudo bash -c "echo 'NoDisplay=true' >> $i"
  sudo bash -c "mv -f $i $HOME/.local/share/applications/"
  sudo chown -R $USER:$USER $HOME/.local/share/applications/
done

# Easyeffects Profiles
mkdir -p $HOME/.config/easyeffects/output
bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh)"

# Autostart syncthing
mkdir -p $HOME/.config/autostart
cp -f /usr/bin/syncthing $HOME/.config/autostart/syncthing

# Firefox touchscreen scrolling fix
[ -f /etc/security/pam_env.conf ] && sudo bash -c 'echo "MOZ_USE_XINPUT2 DEFAULT=1" >> /etc/security/pam_env.conf' || sudo bash -c 'echo "MOZ_USE_XINPUT2 DEFAULT=1" >> /usr/share/security/pam_env.conf'

echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 3-post-setup.sh
-------------------------------------------------------------------------
"
exit
