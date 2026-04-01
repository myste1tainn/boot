#!/bin/bash -
#===============================================================================
#
#          FILE: install-tools.sh
#
#         USAGE: ./install-tools.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: ARNON KEEREENA (a.keereena@gmail.com)
#  ORGANIZATION:
#       CREATED: 05/02/2022 13:51
#      REVISION: ---
#==============================================================================

set -o nounset # Treat unset variables as an error

########################
# Install common tools #
########################

# Install homebrew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install htop
brew install git
brew install jq yq xq
brew install maven
brew install gnu-sed
brew install podman
brew install podman-compose
brew install minikube
brew install coreutils
brew install luarocks
brew install universal-ctags
brew install python3
brew install imagemagick
brew install ffmpeg
brew install rename
brew install pgformatter
brew install rsstail
brew install multitail
brew install mycli
brew install postgresql
brew install pgcli
brew install prometheus
brew install k6 # Load testing tool
brew install derailed/k9s/k9s
brew install kustomize
brew install kompose
brew install xcode-build-server
brew install xcbeautify
brew install ruby
brew install swiftlint
brew install node
brew install tree
brew install poetry
brew install git-delta
brew install gita
brew install fd

brew install debugpy # Python debugger, used for nvim dap
brew install glab gh # GitLab CLI, GitHub CLI
brew install rg fzf
brew install util-linux
brew install pngpaste

pip3 install diagrams

npm install -g yarn
npm install -g prettier @prettier/plugin-xml
yarn global add prisma
yarn global add dotenv-cli
gem install xcodeproj
SDKROOT=$(xcrun --sdk macosx --show-sdk-path) gem install xcode-install

python3 -m pip install -U pymobiledevice3

# setup llvm & lldb for nvim iOS development debugging
# mkdir -p ~/tools/codelldb-aarch64-darwin
# curl -L https://github.com/vadimcn/codelldb/releases/download/v1.10.0/codelldb-aarch64-darwin.vsix -o ~/tools/codelldb-aarch64-darwin/codelldb.zip
# cd ~/tools/codelldb-aarch64-darwin
# unzip codelldb.zip

# Make an alias to lldb for nvim dap for iOS development debugging
# sudo mkdir -p /Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A
# sudo ln -s /opt/homebrew/opt/llvm/bin/lldb /Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Versions/A/LLDB

brew tap mongodb/brew
brew update
brew install mongodb-community@5.0

pip3 install virtualenv
luarocks install luafilesystem

# Install font to be used for vim
brew tap homebrew/cask-fonts
brew install --cask font-victor-mono-nerd-font
brew install font-hack-nerd-font

# OpenSSL
brew install rbenv/tap/openssl@1.0
ln -sfn /usr/local/Cellar/openssl@1.0/1.0.2t /usr/local/opt/openssl

# Install SDKMan & Java 11
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk version
sdk install java 11.0.15-zulu

# Install zsh setup
sh zsh/install.sh

. ~/.bashrc

# Install vim setup
sh vim/install.sh

# Install nvim setup
sh nvim/install.sh

# Install kitty ternmial emulator
# sh kitty/install.sh

# Install macos specifitc scripts
sh macos/install.sh

# Install AeroSpace
sh aerospace/install.sh

# Install hammerspoon
sh hammerspoon/install.sh

# TODO: Add script to install go
# Install delve
go install github.com/go-delve/delve/cmd/dlv@latest
go install gotest.tools/gotestsum@latest
brew install gitleaks || go install github.com/gitleaks/gitleaks/v8@latest

# TODO: This may not work, check it
luarocks --lua-version=5.1 install middleclass

# Install nnn
cd ~/Downloads
git clone https://github.com/jarun/nnn
cd nnn
sudo make O_NERD=1
mv nnn /usr/local/bin

cat <<EOF >>~/.zshrc
# nnn setup
export NNN_FCOLORS='0000E6310000000000000000'
alias nnn "nnn -e"
alias ls "nnn -e"
set --export NNN_FIFO "/tmp/nnn.fifo"
EOF

# Install tools for rust, rust-analyzer, and llvm
# Do this as the last step because it is interactive
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-analyzer
rustup component add rustfmt
brew install llvm

cargo install --locked tree-sitter-cli

echo <<EOF
Install these in vim
:CocInstall coc-rust-analyzer
