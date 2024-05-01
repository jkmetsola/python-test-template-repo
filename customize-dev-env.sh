#!/bin/bash
# shellcheck disable=SC1091
source .env
set -u
{
# shellcheck disable=SC2016
printf '
parse_git_branch() {
  if [ -n "$(git rev-parse --git-dir 2> /dev/null)" ]; then
    echo "($(git rev-parse --abbrev-ref HEAD)) " 
  fi
}
run_tests() {
  robotidy --diff --check hsl-api/tests/robot
  robocop hsl-api/tests/robot
  ruff check --exclude .vscode-server
  ruff format --exclude .vscode-server --diff
  shellcheck ./*.sh
  hadolint Dockerfile
}
export PS1="$PS1\[\033[33m\]\$(parse_git_branch)\[\033[00m\]"
'
echo "
git config --global user.email \"$GIT_EMAIL\"
git config --global user.name \"$GIT_USER\"
"
} >> ~/.bashrc
