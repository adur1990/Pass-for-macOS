#!/bin/bash

set -eox pipefail

HASH=$(shasum -a 256 "$PWD/Pass for macOS.app.zip" | /usr/bin/cut -d" " -f1)
source ./.github/templates/passformacos.sh

git clone git@github.com:adur1990/homebrew-tap.git
cd $PWD/homebrew-tap/

echo -e $CASK_TEMPLATE > $PWD/Casks/passformacos.rb

git config --local user.email "github@artursterz.de"
git config --local user.name "Github Action"

git commit -m "Update Pass for macOS to version $VERSION (automated commit)" -a
git push
