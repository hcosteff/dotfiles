#!/bin/bash

#saner programming env
set -o errexit -o pipefail -o noclobber -o nounset


title() {
  echo -e "\033[0;32m(dotfiles) > $*\033[0m"
}

error() {
  echo -e "\033[0;31m(dotfiles) > $*\033[0m"
}

run_command() {
    title "$@"
    "$@"
}

ALWAYS_YES="n"
if [[ " $* " == *" -y "* ]]; then
    title "ALWAYS_YES"
    ALWAYS_YES="y"
fi

run_command_if_not_exists() {
  target_file=$1
  if [ -e "$target_file" ] || [ -L "$target_file" ]; then
    error "$1 exists"
    old_file="$HOME/oldconfigs/$1_old_$(date +%s)"
    if [[ "$ALWAYS_YES" != "y" ]]; then 
        read -r -p "Move it to $old_file it and proceed? (y/N) " response
        if [[ "$response" != "y" ]]; then
            error "Ok, not removing, skipping installation of $target_file"
            return
        fi
    fi

    dirname_oldfile=$(dirname $old_file)
    title mkdir -p $dirname_oldfile
    mkdir -p $dirname_oldfile
    title mv $target_file $old_file
    echo $old_file >> $HOME/oldconfigs/log
    mv $target_file $old_file
  fi
  shift
  title "$@"
  "$@"
} 
 
if command -v apt-get &> /dev/null; then
  INST="sudo apt-get install -y"
elif command -v yum &> /dev/null; then
  INST="sudo yum install -y"
elif command -v brew &> /dev/null; then
  INST="brew install"
else
  error "None of apt-get, yum, or brew are installed"
  exit 1
fi

title "Will install using '$INST'"


run_command $INST ipython
run_command_if_not_exists $HOME/.ipython/profile_default/startup ln -s $HOME/.dotfiles/ipython_startup/ $HOME/.ipython/profile_default/startup

run_command $INST nvim
run_command_if_not_exists $HOME/.config/nvim ln -s $HOME/.dotfiles/config/nvim $HOME/.config/nvim

if [ "$(basename -- "$SHELL")" = "zsh" ]; then
    run_command_if_not_exists $HOME/.fzf sh -c "git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf; $HOME/.fzf/install --key-bindings --no-completion --no-update-rc"

    if [ ! -e $HOME/.oh-my-zsh ]; then
        ZSH= sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        title "ohmyzsh already exists, skipping"
    fi

    run_command_if_not_exists $HOME/.zshrc  ln -s $HOME/.dotfiles/config/zshrc $HOME/.zshrc
else
    title "Not using ZSH, will not install ohmyzsh and zshrc"
fi


if [[ " $* " == *" --mac "* ]]; then
    run_command brew install koekeishiya/formulae/yabai
    run_command brew install koekeishiya/formulae/skhd
    run_command brew install FelixKratz/formulae/borders

    run_command_if_not_exists $HOME/.bordersrc  ln -s $HOME/.dotfiles/config/bordersrc $HOME/.bordersrc
    run_command_if_not_exists $HOME/.yabairc    ln -s $HOME/.dotfiles/config/yabairc $HOME/.yabairc
    run_command_if_not_exists $HOME/.skhdrc     ln -s $HOME/.dotfiles/config/skhdrc $HOME/.skhdrc
    run_command_if_not_exists $HOME/.gitconfig  ln -s $HOME/.dotfiles/config/gitconfig $HOME/.gitconfig
fi

title "done installing dotfiles"

if [[ " $* " == *" --mac "* ]]; then
    title ""
    title ""
    error ">>> Remember to follow https://github.com/koekeishiya/yabai/wiki#installation-requirements <<<"
fi