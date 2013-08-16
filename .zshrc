# Cyril Robin's ~/.zshrc
# Inspired from Alexis de Lattre (http://formation-debian.via.ecp.fr/)

################
# 1. Les alias #
################

# Gestion du 'ls' : couleur & ne touche pas aux accents
alias ls='ls --classify --tabsize=0 --literal --color=auto --show-control-chars --human-readable'

# Raccourcis pour 'ls'
alias ll='ls -alhF'
alias la='ls -Ah'
alias lr='ls -Rh'
alias l='ls -CFh'
alias llra="ll -R"

# Demande confirmation avant d'écraser un fichier
# et prise en compte de répertoires
alias cp='cp --interactive -r'
alias mv='mv --interactive'
alias rm='rm --interactive -r'

# Quelques alias pratiques
alias c='clear'
alias less='less --quiet'
alias s='cd ..'
alias df='df --human-readable'
alias du='du --human-readable'
alias m='mutt -y'
alias md='mkdir'
alias rd='rmdir'
alias upgrade='sudo apt-get update && sudo apt-get upgrade && sudo apt-get clean'
alias pd="popd"
alias nd="pushd"

alias vim="vim -p"
alias view="view -p"
alias svim="sudo vim"
alias vd="vimdiff"

alias gits="git status"
alias gita="git add"
alias gitap="git add -p"
alias gitc="git commit"
alias gitcm="git commit -m"
alias gitr="git remove"

# alias for todo.txt
alias td="${HOME}/dev/scripts/todo.txt-cli/todo.sh -ant -d ${HOME}/.todo/todo.cfg"
alias d="td"

# alias for Quick Calculator qc
# a shell script using python to compute math in command line
alias qc="${HOME}/dev/scripts/qc.sh"

# alias for swipl (avoid conflicts at compilation)
alias swipl='export LANG=""; swipl'

# alias rsync
alias dotsync="rsync -av ~/.zshrc ~/.zshenv ~/.gitconfig ~/.muttrc ~/.dotfiles/"

#######################################
# 2. Prompt et définition des touches #
#######################################

# The Prompt
autoload -Uz promptinit
promptinit
prompt adam2

# Alternative perso prompt
# Prompt couleur (la couleur n'est pas la même pour le root et
# pour les simples utilisateurs)
#if [ "`id -u`" -eq 0 ]; then
#  export PS1="%{[36;1m%}%T %{[34m%}%n%{[33m%}@%{[37m%}%m %{[32m%}%~ %{[33m%}%#%{[0m%} "
#else
#  export PS1="%{[36;1m%}%T %{[31m%}%n%{[33m%}@%{[37m%}%m %{[32m%}%~ %{[33m%}%#%{[0m%} "
#fi

# Titre de la fenêtre d'un xterm
case $TERM in
   xterm*)
       precmd () {print -Pn "\e]0;%n@%m: %~\a"}
       ;;
esac

# Gestion de la couleur pour 'ls' (exportation de LS_COLORS)
if [ -x /usr/bin/dircolors ]
then
  if [ -r ~/.dir_colors ]
  then
    eval "`dircolors ~/.dir_colors`"
  elif [ -r /etc/dir_colors ]
  then
    eval "`dircolors /etc/dir_colors`"
  else
    eval "`dircolors`"
  fi
fi

# Use vim keybindings 
bindkey -v

# Adapt the color of the prompt to vi mode
# (for rxvt-unicode-256color only ; does not work in tty)
zle-keymap-select () {
    if [ $TERM = "rxvt-unicode-256color" ]; then
        if [ $KEYMAP = vicmd ]; then
            echo -ne "\033]12;Red\007"
        else
            echo -ne "\033]12;Green\007"
        fi
    fi
}
zle -N zle-keymap-select
zle-line-init () {
    zle -K viins
    if [ $TERM = "rxvt-unicode-256color" ]; then
        echo -ne "\033]12;Green\007"
    fi
}
zle -N zle-line-init

# git info in the zsh prompt
autoload -Uz vcs_info

# Color vars
autoload -U colors terminfo
colors

local reset="%{${reset_color}%}"
local white="%{$fg_bold[white]%}"
local green="%{$fg_bold[green]%}"
local red="%{$fg_bold[red]%}"
local blue="%{$fg[blue]%}"
local cyan="%{$fg_bold[cyan]%}"
local magenta="%{$fg[magenta]%}"
local yellow="%{$fg[yellow]%}"

# {{{
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' get-revision true
zstyle ':vcs_info:git*:*' check-for-changes true

#zstyle ':vcs_info:git*' formats "(%s) %12.12i %c%u %b%m" # hash changes branch misc
zstyle ':vcs_info:git*' formats "(%s) %c %b%m" # hash changes branch misc -- no hash displayed
zstyle ':vcs_info:git*' actionformats "(%s|${white}%a) %12.12i %c%u %b%m"

zstyle ':vcs_info:git*+set-message:*' hooks git-st git-stash git-untracked

#zstyle ':vcs_info:git*:*' stagedstr "${green}S${white}"
#zstyle ':vcs_info:git*:*' unstagedstr "${yellow}U${white}"

# Show remote ref name and number of commits ahead-of or behind
function +vi-git-st() {
    local ahead behind remote
    local -a gitstatus

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
        #--symbolic-full-name --abbrev-ref 2>/dev/null)}
        --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    if [[ -n ${remote} ]] ; then
        # for git prior to 1.7
        # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
        ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
        (( $ahead )) && gitstatus+=( "${green}+${ahead}${reset}" )

        # for git prior to 1.7
        # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
        behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
        (( $behind )) && gitstatus+=( "${red}-${behind}${reset}" )

        #hook_com[branch]="${hook_com[branch]} [${remote} ${(j:/:)gitstatus}]"
        hook_com[branch]="[${cyan}${hook_com[branch]}${reset}${(j:/:)gitstatus}]"
    fi
}

# Show count of stashed changes
function +vi-git-stash() {
    local -a stashes

    if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
        stashes=$(git stash list 2>/dev/null | wc -l)
        hook_com[misc]+="${yellow}(stashes #${stashes})${reset}"
    fi
}

# Show count of untracked files
function +vi-git-untracked(){
	if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] then
	    # Untracked
		if git status --porcelain | grep '??' &> /dev/null ; then
	    	local nb_untracked=$(git status --porcelain | grep "\? \?" | wc -l)
		    hook_com[staged]=" ${white}$nb_untracked${red}N${reset}"
		fi
		# Modified
	    if git status --porcelain | grep 'M' &> /dev/null ; then
		    local nb_modified=$(git status --porcelain | grep "M" | wc -l)
		    hook_com[staged]+=" ${white}${nb_modified}${yellow}U${reset}"
		fi
		# Added
	    if git status --porcelain | grep 'A' &> /dev/null ; then
		    local nb_added=$(git status --porcelain | grep "A" | wc -l)
		    hook_com[staged]+=" ${white}${nb_added}${green}S${reset}"
		fi
	fi
}
# }}}

# {{{ precmd()
function precmd {
  
  if [[ $(uname -s) == Linux ]]; then
    vcs_info
  fi
  
    # Prompt on the right, displayed when in a VCS repository
  if [[ $(uname -s) == Linux ]]; then
    #RPS1="${vcs_info_msg_0_}%{${reset_color}%}"
    RPROMPT="${vcs_info_msg_0_}%{${reset_color}%}${white}[%T on %D]"
  fi
  }

# }}}


# Exemple : ma touche HOME, cf  man termcap, est codifiee K1 (upper left
# key  on keyboard)  dans le  /etc/termcap.  En me  referant a  l'entree
# correspondant a mon terminal (par exemple 'linux') dans ce fichier, je
# lis :  K1=\E[1~, c'est la sequence  de caracteres qui sera  envoyee au
# shell. La commande bindkey dit simplement au shell : a chaque fois que
# tu rencontres telle sequence de caractere, tu dois faire telle action.
# La liste des actions est disponible dans "man zshzle".

# Correspondance touches-fonction
bindkey ''    beginning-of-line       # Home
bindkey "\e[1~" beginning-of-line
bindkey "\e[H"  beginning-of-line
bindkey ''    end-of-line             # End
bindkey "\e[4~" end-of-line
bindkey "\e[F"  end-of-line
bindkey ''    delete-char             # Del
bindkey '[3~' delete-char
bindkey '[2~' overwrite-mode          # Insert
bindkey '[5~' history-search-backward # PgUp
bindkey '[6~' history-search-forward  # PgDn

# Prise en charge des touches [début], [fin] et autres
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char


###########################################
# 3. Options de zsh (cf 'man zshoptions') #
###########################################

# Je ne veux JAMAIS de beeps 
unsetopt beep
unsetopt hist_beep
unsetopt list_beep
xset b off
setterm -blength 0

# >| doit être utilisés pour pouvoir écraser un fichier déjà existant ;
# le fichier ne sera pas écrasé avec '>'
unsetopt clobber
# Ctrl+D est équivalent à 'logout'
unsetopt ignore_eof
# Affiche le code de sortie si différent de '0'
setopt print_exit_value
# Demande confirmation pour 'rm *'
unsetopt rm_star_silent
# Correction orthographique des commandes
# Désactivé car, contrairement à ce que dit le "man", il essaye de
# corriger les commandes avant de les hasher
#setopt correct
# Si on utilise des jokers dans une liste d'arguments, retire les jokers
# qui ne correspondent à rien au lieu de donner une erreur
setopt nullglob

# Schémas de complétion

# - Schéma A :
# 1ère tabulation : complète jusqu'au bout de la partie commune
# 2ème tabulation : propose une liste de choix
# 3ème tabulation : complète avec le 1er item de la liste
# 4ème tabulation : complète avec le 2ème item de la liste, etc...
# -> c'est le schéma de complétion par défaut de zsh.

# Schéma B :
# 1ère tabulation : propose une liste de choix et complète avec le 1er item
#                   de la liste
# 2ème tabulation : complète avec le 2ème item de la liste, etc...
# Si vous voulez ce schéma, décommentez la ligne suivante :
#setopt menu_complete

# Schéma C :
# 1ère tabulation : complète jusqu'au bout de la partie commune et
#                   propose une liste de choix
# 2ème tabulation : complète avec le 1er item de la liste
# 3ème tabulation : complète avec le 2ème item de la liste, etc...
# Ce schéma est le meilleur à mon goût !
# Si vous voulez ce schéma, décommentez la ligne suivante :
unsetopt list_ambiguous

# Options de complétion
# Quand le dernier caractère d'une complétion est '/' et que l'on
# tape 'espace' après, le '/' est effacé
setopt auto_remove_slash
# Ne fait pas de complétion sur les fichiers et répertoires cachés
unsetopt glob_dots

# Traite les liens symboliques comme il faut
setopt chase_links

# Quand l'utilisateur commence sa commande par '!' pour faire de la
# complétion historique, il n'exécute pas la commande immédiatement
# mais il écrit la commande dans le prompt
setopt hist_verify
# Si la commande est invalide mais correspond au nom d'un sous-répertoire
# exécuter 'cd sous-répertoire'
setopt auto_cd
# L'exécution de "cd" met le répertoire d'où l'on vient sur la pile
setopt auto_pushd
# Ignore les doublons dans la pile
setopt pushd_ignore_dups
# N'affiche pas la pile après un "pushd" ou "popd"
setopt pushd_silent
# "pushd" sans argument = "pushd $HOME"
setopt pushd_to_home

# Les jobs qui tournent en tâche de fond sont nicé à '0'
unsetopt bg_nice
# N'envoie pas de "HUP" aux jobs qui tourent quand le shell se ferme
unsetopt hup


###############################################
# 4. Paramètres de l'historique des commandes #
###############################################

# The history is shared between all zshell
# And only the last occurrence of duplicates
setopt histignorealldups sharehistory

# Keep 5000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.zsh_history

# Ajoute l'historique à la fin de l'ancien fichier
#setopt append_history

# Chaque ligne est ajoutée dans l'historique à mesure qu'elle est tapée
setopt inc_append_history

# Ne stocke pas  une ligne dans l'historique si elle  est identique à la
# précédente
setopt hist_ignore_dups

# Supprime les  répétitions dans le fichier  d'historique, ne conservant
# que la dernière occurrence ajoutée
#setopt hist_ignore_all_dups

# Supprime les  répétitions dans l'historique lorsqu'il  est plein, mais
# pas avant
setopt hist_expire_dups_first

# N'enregistre  pas plus d'une fois  une même ligne, quelles  que soient
# les options fixées pour la session courante
#setopt hist_save_no_dups

# La recherche dans  l'historique avec l'éditeur de commandes  de zsh ne
# montre  pas  une même  ligne  plus  d'une fois,  même  si  elle a  été
# enregistrée
setopt hist_find_no_dups


###########################################
# 5. Complétion des options des commandes #
###########################################

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


###########################################
# 6. Variables and preferences settings   #
###########################################

# Vim is awesome ! :-)
export EDITOR="vim"

# Language and character encodage
export LANG=en_GB.utf-8
export LANGUAGE=en_GB.utf-8
#export LANG=en_US.utf-8
#export LANG="fr_FR.ISO8859-1"
#export LANG=""

export PATH="${HOME}/dev/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/dev/lib:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${HOME}/dev/lib/i386-linux-gnu:${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${HOME}/dev/lib/pkgconfig:${PKG_CONFIG_PATH}"
export INCLUDE="${HOME}/dev/include:${INCLUDE}"

###########################################
# 7. LAAS Specific Variables              #
###########################################

# Create files writable by group by default
umask 2

# GIT : Set this if you are using a different login on your laptop
export GIT_LAAS_USER=crobin

# OpenRobots / robotpkg
export ROBOTPKG_BASE=${HOME}/LAAS/workspace/tools/openrobots
export PATH=${ROBOTPKG_BASE}/bin:${ROBOTPKG_BASE}/sbin:${PATH}
export LD_LIBRARY_PATH="${ROBOTPKG_BASE}/lib:${ROBOTPKG_BASE}/lib/openprs:${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${ROBOTPKG_BASE}/lib/pkgconfig:${PKG_CONFIG_PATH}"
export PYTHONPATH="/usr/bin/:/usr/lib:/usr/include"
export PYTHONPATH="${PYTHONPATH}:/usr/local/bin/:/usr/local/lib:/usr/local/include:/usr/local/lib/python3/dist-packages/"
#export PYTHONPATH="/usr/bin/:/usr/lib:/usr/include:${HOME}/LAAS/workspace/tools/morse/:${HOME}/LAAS/workspace/tools/morse-laas/:${HOME}/LAAS/workspace/tools/morse-action/"

# ROS
export ROS_OS_OVERRIDE=debian:squeeze
#LANG=en_US.utf-8

export ROS_PACKAGE_PATH=/home/crobin/LAAS/workspace/tools/openrobots/opt/ros/fuerte/
export ROS_MASTER_URI=http://localhost:11311
export PATH="$PATH:/home/crobin/LAAS/workspace/tools/openrobots/opt/ros/fuerte/bin"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/crobin/LAAS/workspace/tools/openrobots/opt/ros/fuerte/lib/pkgconfig"
export PYTHONPATH="$PYTHONPATH:/home/crobin/LAAS/workspace/tools/openrobots/opt/ros/fuerte/lib/python2.7/site-packages"

# For demo genom3
#export PATH="$PATH:/home/crobin/LAAS/Courses/genom3_201310304/dummy-prefix/bin"
#export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/home/crobin/LAAS/Courses/genom3_201310304/dummy-prefix/lib/pkgconfig"
#export PYTHONPATH="$PYTHONPATH:/home/crobin/LAAS/Courses/genom3_201310304/dummy-prefix/lib/python2.7/site-packages"


# Morse
#export MORSE_BLENDER=/home/crobin/LAAS/workspace/tools/blender-2.64a-linux-glibc27-x86_64/blender
#export MORSE_ROOT=${HOME}/LAAS/workspace/tools/

# Environment for Jafar
export JAFAR_DIR=${HOME}/LAAS/workspace/jafar
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${JAFAR_DIR}/lib/x86_64-linux-gnu

# CVS Environment variables
export CVSROOT=ssh://crobin@ncvs.laas.fr/cvs/action 
export CVSROOT=crobin@ncvs.laas.fr/cvs/action 
export CVS_RSH=ssh
export CVSEDITOR=vim

# tkeclipse
export PATH="$PATH:/home/crobin/LAAS/workspace/tools/tkeclipse/bin/x86_64_linux"

######################### /LAAS ####################################
