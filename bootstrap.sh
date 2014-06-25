#!/bin/sh

###### Become sudoer
#su ; visudo ; # add "mylogin ALL=(ALL)ALL" at the end
echo "!!! Warning : you'll need to be sudoer."
echo "Tips : 'su ; visudo ; ' then add '<yourlogin> ALL=(ALL)ALL' at the end"

###### Memo about the source.list
echo "!!! Warning : Please check your source.list"
echo "'sudo vi /etc/apt/source.list' : check for contrib and non-free"

echo "*** Bootstrapping..."

###### Update/Upgrade of the system
echo "*** Updating the system..."
sudo apt-get update

echo "*** Upgrading the system..."
sudo apt-get upgrade

###### Get the main desired packages
echo "*** Installing packages..."
sudo apt-get install \
zsh vim vim-gtk git tig colordiff\
texlive-full rubber tmux\
make make-doc cmake-curses-gui\
awesome awesome-extra slim conky\
i3lock libnotify-bin xfonts-terminus ttf-dejavu xcompmgr alsa-utils \
pavucontrol gnome-bluetooth pulseaudio numlockx rxvt-unicode-256color xsel\
xbacklight wicd cmus \
python-fontforge filezilla calibre \
system-config-printer \
mutt-patched urlview abook\
offlineimap msmtp \
ldbd libnet-ldap-perl \
ffmpeg gparted unetbootin \
uzbl p7zip-rar

###### Other proprietary packages
## For Intel wifi : 
# apt-get install firmware-iwlwifi ;
# modprobe -r iwlwifi ; modprobe iwlwifi
## For Mendeley desktop : check the website
## For Dropbox

###### Set up the shell
echo "*** Setting zsh as default login shell..."
chsh -s /bin/zsh $(whoami)

###### Copy config dot files
DOTFILES=".zsh .gitconfig .cmus .mutt .lesskey"

echo "*** Backuping dotfiles: $DOTFILES ..."
mkdir -p ~/backup_dotfiles
DATE_BAK=$(date +%s)
for dotfile in $DOTFILES; do
    [[ -f ~/${dotfile} ]] && mv ~/${dotfile} ~/backup/bak.${DATE_BAK}${dotfile}
done

echo "*** Copying dotfiles to HOME..."
cd ~/.dotfiles # git clone https://github.com/cyrobin/dotfiles.git ~/.dotfiles
cp -r $DOTFILES ~

# trigger zsh config
sh ~/.zsh/bootstrap.sh

# update less keybindings
lesskey

###### Handle vim config
echo "*** Handling vim config..."
git clone https://github.com/cyrobin/.vim.git ~/.vim
sh ~/.vim/.install.sh

###### Handle awesome config
echo "*** Handling awesome config..."
git clone https://github.com/cyrobin/awesome-wm.git ~/.config/awesome

###### Handle muttrc config
#echo "*** Handling awesome config..."
#TODO

###### Handle Todo.txt ?
#+Dropbox or HubiC for sync ?

###### Get useful scripts
#TODO


###### Remove the @$!# beeps from the speaker
echo "*** Disabling the aggressive beeps"
sudo rmmod pcspkr
sudo echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

###### Cron tasks
#TODO
# Use crontab -e and : 
# Mail quick check every couple of minutes
# 4-59/2 * * * * /usr/bin/offlineimap -q > /dev/null 2>&1
# Mail full check every hour
# 0 * * * * /usr/bin/offlineimap > /dev/null 2>&1
# Rsync LAAS Backup
# 0 13 * * * sh /home/crobin/dev/scripts/make_backup_LAAS.sh


###### Creating other desired repositories
mkdir $HOME/dev

echo "*** Done. Welcome Home ! =)"

#
#echo "Make home folders"
#mkdir work devel openrobots sandbox tmp
#
#[[ "$?" != "0" ]] && echo "Looks like you're already setup" && exit 1
#
