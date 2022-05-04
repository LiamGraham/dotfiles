ALIAS_PATH="$ZSH_CUSTOM/aliases.zsh"

alias vim="nvim" 
alias pip="pip3"
alias python="python3"
alias cat="bat"
alias edit-aliases="vim $ALIAS_PATH && source $ALIAS_PATH"
alias ntest="npm run test"
alias nbuild="npm run build"
alias nbute="npm run build && npm run test"
alias nstart="npm run start"
alias nbust="npm run build && npm run start"
alias nprod="npm run build && npm run start:prod"
alias firefox="open -a /Applications/Firefox.app"
alias gs="git status"
alias cdrepos=". cd $HOME/work/repos/myqld"
alias cdcustom=". cd $ZSH_CUSTOM"
alias co="code ."
alias tu="tilt up"
alias td="tilt down"
alias bi="brew update && brew install"
alias bu="brew update && brew upgrade"