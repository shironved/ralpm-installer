#!/usr/bin/env bash

set -e

INSTALL_DIR="/home/$USER/ralos"

install_apt_packages() {
    sudo apt update
    DEBIAN_FRONTEND=noninteractive sudo apt install --yes fuse unzip tar bzip2 xz-utils wget git
}

install_lxd() {
    # Check if lxd debian package is already installed
    DEB_LXD_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' lxd 2>&1 |grep "install ok installed" || /bin/true)

    # Check if lxd snap package is already installed
    SNAP_LXD_INSTALLED=$(snap list --color=never | grep lxd || /bin/true)

    if [[ "" = "$DEB_LXD_INSTALLED" && "" = "$SNAP_LXD_INSTALLED" ]]; then
        # Neither snap nor lxd version is installed
        DEBIAN_FRONTEND=noninteractive sudo apt install --yes snapd
        sudo snap install lxd
        sudo lxd init --auto
        sudo usermod -aG lxd $USER
        newgrp lxd
    fi
}

install_ralpm() {
    mkdir $INSTALL_DIR
    cd $INSTALL_DIR
    wget "https://github.com/RAL0S/ralos-package-manager/releases/download/2024.05.23/ralpm" -O $INSTALL_DIR/ralpm && chmod +x $INSTALL_DIR/ralpm
    ./ralpm init
    echo "export PATH=\$PATH:$INSTALL_DIR:$INSTALL_DIR/bin/" >> ~/.bashrc
    cd ..

    echo "========================="
    echo "Successfully installed RALOS Package Manager"    
    echo "Run 'ralpm --help' for usage"
    echo
    echo "ralpm has been added to path"
    echo "Logout and re-login for the changes to take effect"
    echo "or run 'source ~/.bashrc' in the current shell"
    echo "========================="
}

if [[ -d "$INSTALL_DIR" ]]; then
    echo "[!] Directory $INSTALL_DIR already exists"
    echo "Please delete the directory and then re-run the install script"
else
    echo "===[ Installing RALOS Package Manager ]==="
    echo ""
    install_apt_packages
    install_lxd
    install_ralpm
fi
