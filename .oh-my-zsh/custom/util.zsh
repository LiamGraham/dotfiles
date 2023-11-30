export REPOS_DIR="$HOME/work"
export GITHUB_USERNAME="liamgraham"
export GITHUB_ORG_NAME=""

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
    git clone git@github.com:$GITHUB_ORG_NAME/$1.git
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

git-all-diffs() {
  local unstaged_changes=$(git diff | diff-so-fancy)
  local staged_changes=$(git diff --staged | diff-so-fancy)

  if [[ -z "$unstaged_changes" && -z "$staged_changes" ]]; then
    return
  fi

  echo -e "\e[1;33mUnstaged Changes:\e[0m"
  if [[ ! -z "$unstaged_changes" ]]; then
    echo "$unstaged_changes"
  else
    echo "No unstaged changes"
  fi

  echo -e "\n\e[1;33mStaged Changes:\e[0m"
  if [[ ! -z "$staged_changes" ]]; then
    echo "$staged_changes"
  else
    echo "No staged changes"
  fi
}

gcloud-activate() {
  gcloud config configurations activate $1 && gcloud auth login
}

