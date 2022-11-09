export GITHUB_USERNAME="liamgraham"

clone-me() {
    if [ -n "$1" ]
    then
        gh repo clone $GITHUB_USERNAME/$1
    else
        echo "Usage: clone-me [repo-name]"
    fi
}

