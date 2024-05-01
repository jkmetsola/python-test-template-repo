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


export PS1="$PS1\[\033[33m\]\$(parse_git_branch)\[\033[00m\]"
'
echo "
git config --global user.email \"$GIT_EMAIL\"
git config --global user.name \"$GIT_USER\"
"
} >> ~/.bashrc


cp .git/hooks/pre-commit.sample .git/hooks/pre-commit
# shellcheck disable=SC2016
sed -i 's|exec git diff-index --check --cached $against --|git diff-index --check --cached $against --|' .git/hooks/pre-commit
{
  echo ""
  echo "robotidy --diff --check hsl-api/tests/robot"
  echo "robocop hsl-api/tests/robot"
  echo "ruff check --exclude .vscode-server"
  echo "ruff format --exclude .vscode-server --diff"
  echo "shellcheck ./*.sh"
  echo "hadolint Dockerfile"
  echo "actionlint"
} >> .git/hooks/pre-commit
