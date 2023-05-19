export REPOS_DIR="$HOME/work"
export GITHUB_USERNAME="liamgraham"

cdiff() {
  if [[ $# -eq 2 ]]; then
    diff -u $1 $2 | diff-so-fancy
  else
    echo "Usage: cdiff FILE1 FILE2"
  fi
}

coverage() {
  if [[ $# -eq 0 ]]; then
    project_dir=$(git rev-parse --show-toplevel)
  elif [[ $# -eq 1 ]]; then
    project_dir=$(readlink -f "$1")
  else
    echo "Usage: coverage [ROOT_DIR]"
    return 1
  fi
  
  if [[ $? -eq 0 ]]; then
    open -a $BROWSER_NAME $project_dir/coverage/lcov-report/index.html 2> /dev/null && \
      echo "📖 Opened coverage for $project_dir" || \
      (richp "$RICH_CROSS Coverage does not exist for $project_dir" 1>&2 && \
      return 1)
  fi
}

idea() {
  if [[ -n "$1" ]]; then 
    open -na "IntelliJ IDEA.app" --args "$1"
  else
    open -na "IntelliJ IDEA.app" --args "`pwd`"
  fi
}

cdroot() {
  project_dir=$(git rev-parse --show-toplevel)

  if [[ $? -eq 0 ]]; then
    . cd "$project_dir"
  fi
}

clone-work() {
  if [ -n "$1" ]
  then
    git clone git@github.com:MaxKelsen/$1.git
  else
    echo "Usage: clone-work [repo-name]"
  fi
}

clone-me() {
  if [ -z "$1" ]; then
    echo "Usage: clone-me [repo-name]"
    return 1
  fi

  gh repo clone $GITHUB_USERNAME/$1
}

cdprop() {
  target_name="core-api"
  if [ $1 ]; then
    target_name=$1
  fi

  cd $REPOS_DIR/mk-propel-$target_name
}

granch() {
  if [ -z "$1" ]
  then
    echo "Usage: granch PATTERN"
    return 1
  fi

  match=$(git branch --format "%(refname:short)" | grep -m 1 "$1")
  if [ -z $match ]; then
    rich -p "[red]! No matching branches found"
    return 1
  fi

  git checkout $match
}

