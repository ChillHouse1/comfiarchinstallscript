#!/bin/sh

# Author : Brandon H.
# NAME: comfiarchinstall
# WARNING: Run at your OWN RISK!
# DEPENDENCIES: dialog

if [ "$(id -u)" = 0 ]; then
    echo "###################################"
    echo "This script MUST NOT BE RUN AS ROOT"
    echo "This script makes changes to the "
    echo "Home directory of the main user"
    echo "The home directory of the root user"
    echo "is '/root'"
    echo "You will be asked for a sudo pswrd"
    echo "when needed during installation."
    echo "###################################"
    exit 1
fi
#func for errors
error() { \
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}
#installing dialog & sync repos 
echo "#########################################################"
echo "## Sync Repos and installing 'dialog' if not installed ##"
echo "#########################################################"
#sudo pacman --noconfirm -needed -Sy dialog || error "Error syncing repos"

welcome() { \
    dialog --colors --title "\Z7\ZbInstalling comfiarchinstall" \
    --msgbox "\Z4This is a script that will install my personal comfort/productivity software/other useful programs. \ 
    This will include programs such as i3wm-gaps, Nvidia drivers, Steam, Freetube, etc. \
    \\n\\n-Brandon" 16 60

    dialog --colors --title "\Z7\ZbStay near your computer!" \
    --yes-label "Continue" \
    --no-label "Exit" \
    --yesno "\Z4This script is not allowed to be ran as root, \
    but you will be asked on occasion to enter your sudo password \
    This is to give pacman the necessary permissions to install programs \
    Please stay near your computer :)" 8 60

}

welcome || error "User chose to exit."

#Confirm Choice
lastchance() { \
    dialog --colors --title "\Z7\ZbInstalling DTOS!" \
    --msgbox "\Z4WARNING! This script is NOT actively maintained, and is only updated when the owner feels like it. \
    If you do not feel comfortable knowing this, please take this chance to exit the installation script. \
    If you feel comfortable knowing this, press 'Begin Installation' to begin." 16 60

    dialog --colors --title "\Z7\ZbAre You Sure You Want To Do This?" \
    --yes-label "Begin Installation" \
    --no-label "Exit" \
    --yesno "\Z4Shall we begin installation?" 8 60 || { clear; exit 1; }
}

lastchance || error "User choose to exit."

#Install packages from pkglist.txt file
sudo pacman --needed --ask 4 -Sy - <pkglist.txt

#copy configs over from /etc/comfi into $HOME

echo "#############################################################"
echo "## Copying configuration files from /etc/comfi into \$HOME ##"
echo "#############################################################"
[ ! -d /etc/comfi ] && sudo mkdir /etc/comfi
[ -d /etc/comfi ] && mkdir ~/comfi-backup-$(date +%Y.%m.%d-%H%M) && cp -Rf /etc/comfi ~/comfi-backup-$(date +%Y.%m.%d-%H%M)
[ ! -d ~/.config ] && mkdir ~/.config
[ -d ~/.config ] && mkdir ~/.config-backup-$(date +%Y.%m.%d-%H%M) && cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H%M)
cd /etc/comfi && cp -Rf . ~ && cd -

# Change all scripts in .local/bin to be executable
find $HOME/.local/bin -type f -print0 | xargs -0 chmod 775

#Installing Paru (aur helper)
echo "###############################################################"
echo "## Installing paru (aur helper). This may take a few minutes.##"
echo "###############################################################"
[ -d ~/.paru.d ] && mv ~/.paru.d ~/.paru.d.bak.$(date +"%Y%m%d_%H%M%S")
[ -f ~/.paru ] && mv ~/.paru ~/.paru.bak.$(date +"%Y%m%d_%H%M%S")
git clone --depth 1 https://github.com/Morganamilo/paru.git ~/.paru.d
~/.paru.d/bin/paru install

echo "##############################################################"
echo "## Installing software from AUR (tor browser, freetube, etc ##"
echo "##############################################################"
paru minecraft-launcher lunar-client lutris-git cbonsai cmatrix bashtop-git rofi-dmenu

#Set Defualt User Shell
PS3='Set default user shell (enter number): '
shells=("fish" "bash" "zsh" "quit")
select choice in "${shells[@]}"; do
    case $choice in
          bash | zsh)
            sudo chsh $USER -s "/bin/$choice" && \
            echo -e "$choice has been set as your default USER shell. \
                    \nLogging out is required for this take effect."
            break
            ;;
         quit)
            echo "User quit without changing shell."
            break
            ;;
         *)
            echo "invalid option $REPLY"
            ;;
    esac
done
loginmanager() { \
        dialog --colors --title "\Z5\ZbInstallation Complete!" \
    --msgbox "\Z2Now logout of your current desktop environment \
                or window manager and choose i3 from your login manager. \
                ENJOY!" 10 60
}

loginmanager && echo "comfiarchscript has run successfully"