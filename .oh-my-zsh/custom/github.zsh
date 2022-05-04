export GITHUB_USERNAME="liamgraham"

clone-me() {
    if [ -n "$1" ]
    then
        gh repo clone $GITHUB_USERNAME/$1
    else
        echo "Usage: gh-me [repo-name]"
    fi
}

clone-work() {
    if [ -n "$1" ]
    then
        gh repo clone myqld/$1
    else
        echo "Usage: gh-me [repo-name]"
    fi
}

repo() {
    if [ -n "$1" ]
    then
        firefox "https://github.com/myqld/$1" 
    else
        REPO_NAME=$(basename `pwd`)
        firefox "https://github.com/myqld/$REPO_NAME"
    fi
}

alias gistl='gh gist list'
alias gistc='gh gist clone' 
