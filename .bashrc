# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Ignore the following commands
export HISTIGNORE='bg:fg'

# Record history right away, rather than after exiting terminal
PROMPT_COMMAND='history -a'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color|xterm-ghostty|xterm-kitty) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1

# Custom function to build the prompt
build_prompt() {
   local venv=""
   if [ -n "$VIRTUAL_ENV" ]; then
      local name=""
      local cfg="$VIRTUAL_ENV/pyvenv.cfg"
      if [ -f "$cfg" ]; then
         name=$(sed -n 's/^prompt *= *//p' "$cfg")
      fi
      venv="(${name:-$(basename "$(dirname "$VIRTUAL_ENV")")}) "
   fi
   PS1="${venv}${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\D{%Y-%m-%d} \[\033[01;32m\]\t \[\033[01;36m\]\u@\h\[\033[00m\]: \w\[\033[00m\]\n\$ "

   if [ "$color_prompt" = yes ]; then
       # Original Prompt
       #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
       normal=$(tput sgr0)
       cyan=$(tput setaf 6)
       #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\u@\h\[\033[00m\]: \w\[\033[00m\]\n\$ '
       PS1="${venv}${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\D{%Y-%m-%d} \[\033[01;32m\]\t \[\033[01;36m\]\u@\h\[\033[00m\]: \w\[\033[00m\]\n\$ "
   else
       # Original Prompt
       #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
       #PS1='${debian_chroot:+($debian_chroot)}\u@\h: \w\n\$ '
       #PS1='${venv}${debian_chroot:+($debian_chroot)}\D{%Y-%m-%d} \t \u@\h: \w\n\$ '
       PS1="${venv}${debian_chroot:+($debian_chroot)}\D{%Y-%m-%d} \t \u@\h: \w\n\$ "
   fi

   # If this is an xterm set the title to user@host:dir
   case "$TERM" in
   xterm*|rxvt*)
       PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
       ;;
   *)
       ;;
   esac
}
#unset color_prompt force_color_prompt

# Tell bash to run this function before every prompt display
PROMPT_COMMAND=build_prompt


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# batcat is good at highlighting code, yaml, markdown, etc. And has a
# built-in pager.
if command -v batcat &>/dev/null; then
   alias b='batcat --plain'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

#-----------------------------------------------------
addpath ()
# Function to add a dir to the end of PATH unless arg2 is "front"
{
	if [ -n $1 ]
	then
      egbin=`which egrep`
		if ! echo $PATH | "$egbin" -q "(^|:)$1($|:)"
		then
			if [ "$2" = "front" ]; then
				PATH=$1:${PATH}
			else
				PATH=${PATH}:$1
			fi
			export PATH
			#echo "PATH is now:"
			#echo $PATH
		fi
	fi
}


addpath "$HOME/titan/bin"
addpath "$HOME/opt/nvim-linux64/bin"
addpath "$HOME/opt/openEMS/bin/"
addpath "$HOME/opt/octave/bin/"
addpath "/usr/local/go/bin"
gpath=$(go env GOPATH)/bin
addpath "$gpath"

# some more ls aliases
alias l='ls -CF'
alias ll='ls -alFh --time-style="+%Y-%m-%d %H:%M:%S"'
alias la='ls -A'
alias lt='ls -lrth --time-style="+%Y-%m-%d %H:%M:%S"'
alias ltd='ls -lrthd --time-style="+%Y-%m-%d %H:%M:%S"'
# List by groups:
#  - group directories first
#  - LOC_COLLATE=C forces case to be important, which groups .xxxx and _xxxx
#    files. setting the environment variable before issuing the command makes
#    that variable change only for the command being issued.
#  - force hidden files, except .. and . to be displayed with -A
alias lg='LC_COLLATE=C ls -A --group-directories-first'
alias hgrep="history|grep"
alias agrep="alias|grep"
alias ha="history -a"
alias resh='source ~/.bashrc'

if command -v git &>/dev/null; then 
   #alias gitlog='git log --reverse --pretty'
   alias gitlog='git log --pretty --decorate'
   alias gitl='git log --oneline --decorate -n 30'
   alias gitci='git commit -a'
   alias gitpu='git push origin master'
fi
if command -v gitk &>/dev/null; then 
   alias gitka='gitk --all'
fi

function gitsha () {
   if command -v git &>/dev/null; then 
      rev=${1:-"HEAD"}
      sha=$(git rev-parse HEAD)

      if command -v pbcopy &>/dev/null; then 
         echo ${sha} | tr -d '\n' | pbcopy
         echo "$sha copied to clipboard"
      elif command -v xclip &>/dev/null; then 
         echo ${sha} | tr -d '\n' | xclip -sel clip
         echo "$sha copied to clipboard"
      else
         echo "$sha"
      fi
   fi
}


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Support for TitanPlayer
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/russ/Documents/projects/titan/bin/

######################################################
function md()
# markdown processing into HTML
#
# This function looks for two possible css files to use with pandoc to create
# an HTML file from a markdown file
#
# The css files can be found at:
# - https://gist.github.com/ryangray/1882525
# - https://gist.github.com/Dashed/6714393
#
# Example: md README.md
######################################################
{
   filename=$(basename "$1")
   extension="${filename##*.}"
   base="${filename%.*}"
   outfile=$base.html

   if [ "$extension" = "md" ]; then
      if [ -f buttondown.css ] ; then
         css="--css buttondown.css"
      elif [ -f $HOME/buttondown.css ] ; then
         css="--css $HOME/buttondown.css"
      elif [ -f $HOME/github-pandoc.css ] ; then
         css="--css $HOME/github-pandoc.css"
      fi
      #echo "css = $css"

      if command -v pandoc &>/dev/null; then
         cmd="pandoc -s -f commonmark $css $1 -o $outfile --metadata title=$base"
         echo "$cmd"
         $cmd
      else
         echo "md(): can't find pandoc"
      fi
   elif [ "$extension" = "rst" ]; then
      if command -v pandoc &>/dev/null; then
         echo pandoc -f rst $1 -o $outfile
         pandoc -f rst $1 -o $outfile
      fi
   else
      echo "Unknown input document type. Not processing it."
   fi
}

######################################################
function mdv()
# markdown view: convert a markdown file to HTML, and view in firefox
# Example: mdv README.md
######################################################
{
   #outfile="/tmp/mdv.html"
   outfile="`basename $1 .md`.html"
   md $1 
   if [[ "$unamestr" == 'Darwin' ]]; then
      open $outfile &
   else
      firefox $outfile &
   fi
   #if [[ "$unamestr" == 'Linux' ]]; then
   #elif [[ "$unamestr" == 'FreeBSD' ]]; then
}

######################################################
cl()
# cat last: find the most recent file and cat it.
# Example: cl "log/*.log"
# Example: cl # everything in the current directory
######################################################
{
   #echo "arg 1 = $1"
   #echo "# = $#"
   if [ $# -ne 1 ] ; then
      files="."
   else
      files=$1
   fi
   #echo "files = $files"
   fname=`ls -rt $files|tail -n 1`
   if [ -d "$files" ] ; then
      #echo "found dir"
      fname=$files/$fname
   fi
   echo "showing last file: $fname"
   cat $fname
}

######################################################
fclip() {
# Function: fclip (File to Clipboard)
# Usage: fclip <file_name>
# Action: Reads the content of the specified file and puts it into the system clipboard.
######################################################
    if [ -z "$1" ]; then
        echo "Error: No file specified."
        echo "Usage: fclip <file_name>"
        return 1
    elif [ ! -f "$1" ]; then
        echo "Error: File '$1' not found or is not a regular file."
        return 1
    fi

    # Check if xclip is installed
    if ! command -v xclip &> /dev/null
    then
        echo "Error: xclip is not installed. Please install it (e.g., sudo apt install xclip)."
        return 1
    fi

    # Use 'cat' to output the file and pipe to 'xclip'
    cat "$1" | xclip -selection clipboard

    # Optional confirmation message
    echo "Content of '$1' copied to clipboard."
}

######################################################
clipf() {
# Function: clipf (Clipboard to File)
# Usage: clipf <file_name> [append]
# Action: Pastes the content of the system clipboard into the specified file.
#         Use 'append' as the second argument to append instead of overwrite.
######################################################
    if [ -z "$1" ]; then
        echo "Error: No file name specified."
        echo "Usage: clipf <file_name> [append]"
        return 1
    fi

    # Check if xclip is installed
    if ! command -v xclip &> /dev/null
    then
        echo "Error: xclip is not installed. Please install it (e.g., sudo apt install xclip)."
        return 1
    fi

    # Check for the optional 'append' argument
    if [ "$2" == "append" ]; then
        # Use 'xclip' to output clipboard contents and append (>>) to file
        xclip -selection clipboard -out >> "$1"
        echo "Clipboard content appended to '$1'."
    else
        # Use 'xclip' to output clipboard contents and overwrite (>) the file
        xclip -selection clipboard -out > "$1"
        echo "Clipboard content written to '$1' (overwritten)."
    fi
}

alias venv_montera="source $HOME/Documents/projects/Olympus/montera/scripts/.venv/bin/activate"
alias venv_gd="source $HOME/Documents/projects/gnss-diff/env_diff/bin/activate"
alias venv_pi="source $HOME/Documents/projects/gnss-programmatic/.venv/bin/activate"
alias venv_drive="source $HOME/Documents/projects/judo-radio-utils/drivetest/env_drive/bin/activate"
alias venv_jenkins="source $HOME/Downloads/_Judo_Firmware/env_jenkins/bin/activate"

alias hdfview="flatpak run org.hdfgroup.HDFView"

export PICO_SDK_PATH=/home/russ/Documents/projects/pico-sdk/
alias xcfile="xsel --clipboard --output > "
alias xccb="cat your_file.txt | xclip -selection clipboard"


# Judo Yocto Stuff
#
# Setup common downloads and sstate directories to be shared by all Yocto/OE
# builds.
#

export DL_DIR="$HOME/Yocto/Downloads"
mkdir -p "$DL_DIR"

export SSTATE_DIR="$HOME/Yocto/SState"
mkdir -p "$SSTATE_DIR"

if [ -f ~/.bash_secrets ]; then
    . ~/.bash_secrets
fi

# Variables we need bitbake to get from environment.
MY_PASSTHROUGH_ADDITIONS=(
    DL_DIR
    SSTATE_DIR
    ARTIFACTORY_WEBUI_USR
    ARTIFACTORY_WEBUI_TOK
)
export BB_ENV_PASSTHROUGH_ADDITIONS="${BB_ENV_PASSTHROUGH_ADDITIONS} ${MY_PASSTHROUGH_ADDITIONS[@]}"
