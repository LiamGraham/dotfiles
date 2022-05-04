export REPOS_DIR="$HOME/work/repos"

set-npm-private() {
  npm config set email "liam.graham@chde.qld.gov.au"
  npm config set registry "https://npm.devops.myqld.developer.qld.gov.au/repository/npm-all/"
  npm config set _auth ""
  npm config set always-auth true
  echo "✅ Changed to work NPM registry"
}

set-npm-public() {
  npm config delete registry
  npm config delete _auth
  echo "✅ Changed to default NPM registry"
}

set-current-project() {
  if [ -n "$1" ]; then 
    export CURRENT_PROJECT=$1
  else
    echo "Usage: set-current-project [dir]"
  fi
}

set-current-here() {
  export CURRENT_PROJECT=`pwd`
  echo "Current project set to $CURRENT_PROJECT"
}

coverage() {
  if [[ -v CURRENT_PROJECT ]]; then
    open -a /Applications/Firefox.app $CURRENT_PROJECT/coverage/lcov-report/index.html
    echo "📖 Opened coverage for $CURRENT_PROJECT"
  else
    echo "⚠️  \$CURRENT_PROJECT is not set. Use set-current-project first."
  fi
}

idea() {
  if [ -n "$1" ]; then 
    open -na "IntelliJ IDEA.app" --args "$1"
  else
    open -na "IntelliJ IDEA.app" --args "`pwd`"
  fi
}

