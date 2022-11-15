#!/bin/zsh

set -o errexit

PROGNAME=$0

print_usage() {
  cat <<EOF
$PROGNAME <command> <repository name> [<branch>]

Available commands are:

  show        Display current branch protection settings for the selected
              branch

  protect     Protect the selected branch

  unprotect   Unprotect the selected branch

Repository names must be given in 'OWNER/repo' form.  The branch defaults to
'master' if not given.
EOF
}

action=$1
REPO=$2
BRANCH=${3-master}

if [[ -z $REPO && -d .git ]]; then
  repo_url=$(git remote get-url origin)
  REPO=$(echo $repo_url | sed -e 's/^git@github.com:\(.*\)$/\1/; s/\.git$//')
fi

if [[ $REPO != */* ]]; then
  echo 'Invalid repository name'
  exit 1
fi

case $action in
  protect|unprotect|show|show_all) ;;
  *)
    print_usage
    exit 1
esac

TOKEN_FILE=$HOME/.config/github_token

echo $action $REPO $BRANCH

_read_token() {
    head -1 $TOKEN_FILE
}

GITHUB_API_TOKEN=$(_read_token)

show() {
  http  get https://api.github.com/repos/$REPO/branches/$BRANCH/protection Authorization:token\ $GITHUB_API_TOKEN Accept:application/vnd.github.luke-cage-preview+json
}

protect() {
  http --ignore-stdin put https://api.github.com/repos/$REPO/branches/$BRANCH/protection Authorization:token\ $GITHUB_API_TOKEN Accept:application/vnd.github.luke-cage-preview+json \
    required_status_checks:='{
      "strict": true,
      "contexts": []
    }' \
    required_pull_request_reviews:='{
      "dismissal_restrictions": {},
      "dismiss_stale_reviews": false,
      "require_code_owner_reviews": false,
      "required_approving_review_count": 1
    }' \
    enforce_admins:=true \
    restrictions:=null
}

unprotect() {
  http delete https://api.github.com/repos/$REPO/branches/$BRANCH/protection/required_pull_request_reviews Authorization:token\ $GITHUB_API_TOKEN
}

$action
