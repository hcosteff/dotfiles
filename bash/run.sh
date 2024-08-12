
HISTCONTROL=ignoreboth
HISTSIZE=200000
HISTFILESIZE=200000
setopt nosharehistory

zstyle ':completion:*' completer _expand _complete

# add ~/bin to path
PATH=$PATH:~/bin
PATH=$PATH:~/.dotfiles/bin


zle -A emacs-forward-word forward-word
zle -A emacs-backward-word backward-word



iterm_settabcolors

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh || echo "Forgot to install fzf?"
[ -f ~/.iterm2_shell_integration.zsh ] && source ~/.iterm2_shell_integration.zsh || echo "Forgot to install iterm2_shell_integration?"

HOMEBREW_AUTO_UPDATE_SECS=7890000