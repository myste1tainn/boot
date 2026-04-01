#!/bin/bash - 
#===============================================================================
#
#          FILE: install.sh
# 
#         USAGE: ./install.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (ICE), 
#  ORGANIZATION: 
#       CREATED: 12/16/2021 08:38
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

## Prerequisites
brew install node
brew install luajit
brew install lua-language-server

## Install vim-plug first
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

rm -rf ~/.vimrc*

sh $SCRIPT_PATH/linkfiles.sh

vim +PlugInstall +qall

# These scripts won't work you'll have to run this yourself in vim
echo 'vim :LspInstall dockerls gopls jdtls yamlls jsonls html angularls cssls dotls pyright sourcekit vimls bashls sumneko_lua lemminx'
