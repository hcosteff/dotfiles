# Source global definitions

alias grpe=grep
alias gdt="git difftool"
alias gmt="git mergetool"


alias dotalias="sub ~/.dotfiles/bash/aliases.sh"
alias dotrun="sub ~/.dotfiles/bash/run.sh"

alias dotinst="sub ~/.dotfiles/install.sh"
alias dotv="sub ~/.dotfiles/config/nvim/init.vim"
alias dotgit="sub ~/.dotfiles/config/gitconfig"
alias dotzshrc="sub ~/.dotfiles/config/zshrc"

alias dotuseful="sub ~/.dotfiles/ipython_startup/useful.py"
alias dotunpolished="sub ~/.dotfiles/ipython_startup/unpolished.py"

alias dotsheepdog="sub ~/.dotfiles/bin/sheepdog"

alias dotjankyborders="sub ~/.dotfiles/config/bordersrc"
alias dotyabai="sub ~/.dotfiles/config/yabairc"
alias dotskhd="sub ~/.dotfiles/config/skhdrc"


function glg() {
    git lg | head -n10000 | grep "$(git rev-parse --short $(git getbase))" -B 999
}

function git_branches_by_date() {
    git for-each-ref --sort=-committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'
}


stringsum() {
    echo "md5sum,md5" | tr ',' '\n' | while read -r cmd; do
        if [[ -x "$(command -v "${cmd}")" ]]; then
            num=$(( 0x$(echo "$1" | command "${cmd}" | cut -d ' ' -f 1 | head -c 15) ))
            [[ $num -lt 0 ]] && num=$((num * -1))
            echo $num
            return 0
        fi
    done
    return 1
}


iterm_window_id() {
    osascript -e '
    tell application "iTerm2"
        tell current window
            return id
        end tell
    end tell
    '
}

iterm_num_splits() {
    osascript -e '
    tell application "iTerm2"
        tell current tab of current window
            return count of sessions
        end tell
    end tell'
}

#npm install -g iterm2-tab-set
function iterm_settabcolors() {
    name="$(docker-name-gen)"
    colors=("000000" "000010" "000020" "001000" "001010" "001020" "002000" "002010" "002020" "100000" "100010" "100020" "101000" "101010" "101020" "102000" "102010" "102020" "200000" "200010" "200020" "201000" "201010" "201020" "202000" "202010" "202020" )
    R=$(cksum <<< "$(iterm_window_id)" | cut -f 1 -d ' ')
    # Randomly select a color from the array
    bg_color=${colors[$R % ${#colors[@]}]}
    DISABLE_AUTO_TITLE='true'
    echo -e "\033]Ph${bg_color}\033\\"

    if [ "$(iterm_num_splits)" -eq 1 ]; then 
        tabset  --mode 2 "$name"
    else
        tabset  --badge "$name"
    fi
}

alias biggest-files-in-dir="du -aBM 2>/dev/null | sort -nr | head"


function witch ()
{
    if [[ "$OSTYPE" == "darwin"* ]]; then
      functype=`type -w $1 | cut -d ' ' -f2`
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
      functype=`type -t $1`
    else
      echo "This is neither a Mac nor a Linux system."
      exit
    fi

    echo $functype
    case "$functype" in
        alias)
            alias $1
        ;;
        function)
            type -a $1
            typeset -f $1
        ;;
        file)
            /usr/bin/which $1
            echo -en "\033[32mShow file ?\033[0m " 1>&2;
            read -t 5 answer;
            if [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "yes" ]]; then
                less -# 10 `which $1`;
            fi
        ;;
        command)
            /usr/bin/which $1
            echo -en "\033[32mShow file ?\033[0m " 1>&2;
            read -t 5 answer;
            if [[ "$answer" == "y" || "$answer" == "Y" || "$answer" == "yes" ]]; then
                less -# 10 `which $1`;
            fi
        ;;
        *)
            echo 'Error : wrong name !';
            echo;
            echo "Usage: witch ALIAS|FUNCTION|FILE";
            return 1
        ;;
    esac
}

function sourced
{
    /bin/bash -lixc exit 2>&1 | sed -n 's/^+* \(source\|\.\) //p'
}

function replace()
{
    grep $1 | xargs -I {} sed "s/$1/$2/" {}
}


function hex {
    python3 -c "print(hex($1))"
}

function unhex {
    echo $1 | grep 0x > /dev/null
    if [ $? -eq 0 ]
    then
        python3 -c "print($1)"
    else
        python3 -c "print(0x$1)"
    fi   
}

function sumlines() {
    python -c "import sys; print(sum(int(l) for l in sys.stdin))"
}

function timer()
{
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')
        if [[ -z "$stime" ]]; then stime=$etime; fi
        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

function delete_backup()
{
    echo 'find . -type f \( -name "*_BACKUP_*" -o -name "*_LOCAL_*" -o -name "*_REMOTE_*" \)'
}
