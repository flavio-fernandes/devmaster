#!/usr/bin/env bash

repo="flavio-fernandes/dotfiles.git"
repo_https="https://github.com/$repo"
repo_git="git@github.com:$repo"
branch="flaviof"

[ -d "${HOME}/.dotfiles" ] && {
    cd ${HOME}/.dotfiles
    git pull -f --depth 1 "$repo_https" "$branch"
} || {
    git clone --no-single-branch --depth 1 "$repo_https" ${HOME}/.dotfiles
    cd ${HOME}/.dotfiles
    git remote add upstream "$repo_git"
    [ -n "$branch" ] && git checkout "$branch"
}

stow zsh git code-server
