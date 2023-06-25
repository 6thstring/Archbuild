#!/bin/bash

# Find the name of the folder the scripts are in
set -a
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPTS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/scripts
CONFIGS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
set +a
echo -ne "
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------
                Scripts are in directory named Archbuild
"
    ( bash $SCRIPT_DIR/scripts/startup.sh )|& tee startup.log
      source $CONFIGS_DIR/setup.conf
    ( bash $SCRIPT_DIR/scripts/0-preinstall.sh )|& tee 0-preinstall.log
    ( arch-chroot /mnt $HOME/Archbuild/scripts/1-setup.sh )|& tee 1-setup.log
    if [[ ! $DESKTOP_ENV == server ]]; then
      ( arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- /home/$USERNAME/Archbuild/scripts/2-user.sh )|& tee 2-user.log
    fi
    ( arch-chroot /mnt $HOME/Archbuild/scripts/3-post-setup.sh )|& tee 3-post-setup.log
    cp -v *.log /mnt/home/$USERNAME
    chown $USERNAME:$USERNAME /mnt/home/$USERNAME*.log

    if [[ $DESKTOP_ENV == "kde" && $INSTALL_TYPE == "FULL" ]]; then
      echo -ne "
      -------------------------------------------------------------------------
                  Run scripts/4-postboot-setup.sh after rebooting
      -------------------------------------------------------------------------
      "
      cp -f $SCRIPT_DIR/scripts/4-postboot-setup.sh /mnt/home/$USERNAME/4-postboot-setup.sh
      chown $USERNAME:$USERNAME /mnt/home/$USERNAME/4-postboot-setup.sh
      chmod +x /mnt/home/$USERNAME/4-postboot-setup.sh
    fi

echo -ne "
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
-------------------------------------------------------------------------
                Done - Please Eject Install Media and Reboot
"
