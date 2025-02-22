#!/bin/bash

set -ex

if [ -z "$GITHUB_ACTIONS" ]
then
  echo "not setting up git as not in a GitHub Action"
else
  echo "lets setup git"
  git config user.name github-actions
  git config user.email github-actions@github.com
  git config --global --add safe.directory /github/workspace  
fi

git clone https://github.com/jenkins-x-plugins/jx-plugin-doc

pushd jx-plugin-doc
  make build
popd

jx-plugin-doc/build/jx-plugin-doc $(pwd)

echo "ran the generator"

ls jx-plugins

echo generated 
ls -l content/en/v3/develop/reference/jx

git add content/en/v3/develop/reference/jx
git status

if git diff --exit-code  --quiet
then
    echo "::set-output name=changed::false"
else
    git checkout -b regen-plugin-docs-$(date +%Y%m%d-%H%M%S)
    echo "::set-output name=changed::true"
fi
