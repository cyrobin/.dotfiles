#!/bin/sh

echo "*** Bootstrapping..."

###### Update/Upgrade of the system
echo "*** Updating the system..."
sudo apt-get update

echo "*** Upgrading the system..."
sudo apt-get upgrade

###### Get the main desired packages
echo "*** Installing packages..."
sudo apt-get install \
zsh vim vim-gtk git tig colordiff \
texlive-full rubber tmux \
make make-doc cmake-curses-gui \
awesome awesome-extra slim conky \
i3lock libnotify-bin xfonts-terminus ttf-dejavu xcompmgr alsa-utils \
pavucontrol gnome-bluetooth pulseaudio numlockx rxvt-unicode-256color xsel\
xbacklight wicd cmus \
python-fontforge filezilla calibre \
system-config-printer-common \
mutt-patched urlview abook \
offlineimap msmtp \
gparted unetbootin \
calibre synaptic

###### Other proprietary packages
# For Mendeley desktop : check the website
# For Dropbox

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
cd ~/.dotfiles # git clone git://github.com/cyrobin/dotfiles.git ~/.dotfiles
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
#echo "*** Handling muttrc config..."
#TODO

###### Handle Todo.txt ?
#+Dropbox or HubiC for sync ?

###### Get useful scripts
echo "Setting ~/dev and Getting useful scripts..."
mkdir -p ~/dev
mkdir -p ~/dev/src
git clone https://github.com/cyrobin/scripts.git ~/dev/src/scripts
cd ~/dev/src/scripts && git submodule update --init
cd $HOME

###### Handle awesome-wm config
echo "*** Handling awesome-wm config..."
cd $HOME
rm -rf ~/.config/awesome
git clone https://github.com/cyrobin/awesome-wm.git ~/.config/awesome

###### Remove the @$!# beeps from the speaker
echo "*** Disabling the aggressive beeps"
sudo rmmod pcspkr
sudo echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

###### Cron tasks
#TODO
# Use crontab -e and edit

###### Set up ssh
echo "Setting ssh up"
cd $HOME
ssh-keygen -C "$(whoami)@$(hostname)-$(date -I)"

echo "*** Done. Welcome Home ! =)"
