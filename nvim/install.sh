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


## Install vim-plug first (copy over from vim)
mkdir -p ~/.local/share/nvim/site/autoload
cp ~/.vim/autoload/plug.vim ~/.local/share/nvim/site/autoload

## Install packer, like vim-plug but for some nvim packages 
mkdir -p ~/.local/share/nvim/site/pack/packer/start/packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim


sh $SCRIPT_PATH/linkfiles.sh

# Requires by nvim/telescope.nvim for "rg" or live_grep functions
brew install ripgrep
python3 -m pip install --user --upgrade pynvim

vim +PlugInstall +qall
vim +PackerSync +qall

## For nvim-jdtls integration with nvim-dap
# Install java-debug
cd /tmp
git clone https://github.com/microsoft/java-debug
cd java-debug
./mvnw clean install
mkdir -p ~/.local/share/nvim/java-debug/ 
cp /tmp/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar ~/.local/share/nvim/java-debug/
# Install vscode-java-test
cd /tmp
git clone https://github.com/microsoft/vscode-java-test
cd vscode-java-test
npm install
npm run build-plugin
mkdir -p ~/.local/share/nvim/vscode-java-test/ 
cp /tmp/vscode-java-test/server/*.jar ~/.local/share/nvim/vscode-java-test/

# Install Lua make for lua debugging
# ./build/macos/bin/luamake

# These scripts won't work you'll have to run this yourself in vim
echo 'vim :LspInstall dockerls gopls jdtls yamlls jsonls html angularls cssls cssmodules_ls dotls pyright sourcekit vimls bashls sumneko_lua lemminx dartls tsserver sqlls ccls'
