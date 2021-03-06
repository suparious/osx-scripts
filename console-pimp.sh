#!/bin/bash
## Helper script to setup a cool looking terminal
#
# Using ITerm2:
#    - https://www.iterm2.com/downloads.html
# Using Oh My ZSH from:
#    - https://github.com/robbyrussell/oh-my-zsh
# Using PowerLine fonts from:
#    - https://github.com/powerline/fonts
# Using Bullet-Train theme for OhMyZSH:
#    - https://github.com/caiogondim/bullet-train.zsh

## INstalling Iterm2 (OSX) or PuTTY (windows)
# do this yourself
echo "Amazing!"

## OhMyZsh
# Install directly from github 
cd # go home, asshole
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## PowerLine fonts
cd # go home, asshole
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts

## Bullet-Train time
zsh
cd $ZSH_CUSTOM/themes/
wget http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme

## Configure ~/.zshrc or use this example
# https://raw.githubusercontent.com/suparious/osx-scripts/master/console-pimp.zshrc