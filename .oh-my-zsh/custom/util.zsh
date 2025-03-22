export REPOS_DIR="$HOME/work"
export GITHUB_USERNAME="liamgraham"
export GITHUB_ORG_NAME="workcover-qld"

# Returns value corresponding to given key in specified mapping file. Mapping file must consist of new-line separated "key=value" pairs.
get_value_for_key() {
  local target_key="$1"
  local file_path="$2"

  while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line == "$target_key="* ]]; then
      echo "${line#*=}"
      return
    fi
  done < "$file_path"
}

cdiff() {
  if [[ $# -eq 2 ]]; then
    diff -u $1 $2 | diff-so-fancy
  else
    echo "Usage: cdiff <file1> <file2>"
  fi
}

check_and_open() {
  local port=$1
  local max_retries=${2:-10}
  local retry_interval=${3:-0.5}
  local attempts=0

  while [ $attempts -lt $max_retries ]; do
      if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" | grep -q "200"; then
          open "http://localhost:$port"
          exit 0
      fi
      attempts=$((attempts + 1))
      sleep $retry_interval
  done
  echo "Failed to connect to server after $max_retries attempts" >&2
  exit 1
}

coverage() {
  if [[ $# -eq 0 ]]; then
    project_dir=$(git rev-parse --show-toplevel)
  elif [[ $# -eq 1 ]]; then
    project_dir=$(readlink -f "$1")
  else
    echo "Usage: coverage <root-dir>"
    return 1
  fi

  local port=3721
  
  if [[ $? -eq 0 ]]; then
    ( check_and_open $port & ); npx vite --port $port --strictPort --clearScreen false $project_dir/coverage
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
    echo "Usage: clone-work <repo-name>"
  fi
}

clone-me() {
  if [ -z "$1" ]; then
    echo "Usage: clone-me <repo-name>"
    return 1
  fi
  git clone git@github-personal:$GITHUB_USERNAME/$1
}

grep-git-checkout() {
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

fzf-git-branch() {
  git rev-parse HEAD > /dev/null 2>&1 || return

  git branch --color=always --sort=-committerdate |
      grep -v HEAD |
      fzf --height 50% --ansi --no-multi --preview-window right:65% \
          --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
      sed "s/.* //"
}

fzf-git-checkout() {
  git rev-parse HEAD > /dev/null 2>&1 || return

  local branch

  branch=$(fzf-git-branch)
  if [[ "$branch" = "" ]]; then
      echo "No branch selected."
      return
  fi

  # If branch name starts with 'remotes/' then it is a remote branch. By
  # using --track and a remote branch name, it is the same as:
  # git checkout -b branchName --track origin/branchName
  if [[ "$branch" = 'remotes/'* ]]; then
      git checkout --track $branch
  else
      git checkout $branch;
  fi
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


open-vercel-dashboard() {
  local base_url="https://vercel.com/liamgrahams-projects"
  local project_dir=${$(git rev-parse --show-toplevel):t}
  open -a $BROWSER_NAME -g $base_url/$project_dir
  osascript -e "tell application \"$BROWSER_NAME\" to activate"
}

assume() {
  . awsume "$@"

  local stripe=$(get_value_for_key "$AWSUME_PROFILE" "$ACCOUNT_STRIPE_MAPPING_PATH")

  if [[ -v stripe ]]; then
    export TARGET_ENV=$AWSUME_PROFILE
    export ACTIVE_STRIPE=$stripe
  local mapped_stripe=$(get_value_for_key "$target_env" "$ACCOUNT_STRIPE_MAPPING_PATH")
    export TARGET_STRIPE=$stripe
    export CLUSTER_NAME="${TARGET_ENV}-${TARGET_STRIPE}"
  fi
}

list-eks-clusters() {
  for cluster in $(aws eks list-clusters --query 'clusters[*]' --output text)
  do
      rich -p "[bold]$cluster"
      aws eks describe-cluster --name $cluster --query 'cluster.{Name:name,Status:status,Version:version}' --output yaml | yq
      echo
  done
}

git-edit-branch() {
  # Get current branch name
  current_branch=$(git symbolic-ref --short HEAD)
  
  new_branch=$current_branch
  
  vared -p "> " new_branch
  
  if [[ -n "$new_branch" && "$new_branch" != "$current_branch" ]]; then
    git branch -m "$new_branch"
    echo "Branch renamed to: $new_branch"
  else
    echo "No changes made"
  fi
}

git-smart-commit() {
  local commit_type="feat"

  # Check if -f or --fix flag is provided
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--fix)
        commit_type="fix"
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  branch=$(git branch --show-current)
  number=$(echo $branch | grep -o "cloud-[0-9]\+" | grep -o "[0-9]\+")
  
  # If no number is found, default to "00"
  if [ -z "$number" ]; then
    number="00"
  fi
  
  git commit -m "$commit_type: CLOUD-$number $*"
}

