#!/bin/bash - 
#===============================================================================
#
#          FILE: init-mac-os.sh
# 
#         USAGE: ./init-mac-os.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 05/02/2022 13:44
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Alfred
bash $SCRIPT_PATH/dmg-installer.sh 'https://cachefly.alfredapp.com/Alfred_5.6.2_2296.dmg' &

# Dropbox
bash $SCRIPT_PATH/dmg-installer.sh 'https://dl-web.dropbox.com/installer?arch=x86_64&build_no=225.4.4896&plat=mac&tag=DBPREAUTH%3A%3Achrome%3A%3AeJwNy7EKwjAQANBfKTeL3CW53MXNwTpYF3HRpQgGLcWUNm2liP-ub38fuE3jsx67NibYFLBUw7aKh_OS-v2s1_mi5ePdHnf5ZMvwmmRN4lSY2VhYFZBjzk2X6ub-zxRYrCATSbCKrM4YVVRHxAY5eCTnPX9_OmAggQ~~%40META&tag_token=AhIbiKwG4GcRyuMFMmPnepqqww68ulx2n8jHlQqb-Zs2sg' &

# Brave
bash $SCRIPT_PATH/dmg-installer.sh 'https://referrals.brave.com/latest/Brave-Browser-arm64.dmg' &
bash $SCRIPT_PATH/dmg-installer.sh 'https://referrals.brave.com/latest/Brave-Browser.dmg' &

# Mos
bash $SCRIPT_PATH/dmg-installer.sh 'https://objects.githubusercontent.com/github-production-release-asset-2e65be/80204710/0ed45680-744e-11eb-9936-7b6e083e10d6?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20220502%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20220502T041603Z&X-Amz-Expires=300&X-Amz-Signature=9f590190f2551e02a47adfefcb07141fde6a8e8936b36ab34773727a3dfbe9a2&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=80204710&response-content-disposition=attachment%3B%20filename%3DMos.Versions.3.3.2.dmg&response-content-type=application%2Foctet-stream'

# KensingtonWorks
bash $SCRIPT_PATH/dmg-installer.sh 'https://www.kensington.com/siteassets/software-support/kensingtonworks/new-kensingtonworks-download/kensingtonworks_3.0.3_1640160151.pkg'

# Typora
bash $SCRIPT_PATH/dmg-installer.sh 'https://typora.io/mac/Typora.dmg'

# Dozer - Hide Menu Bar Icons
bash $SCRIPT_PATH/dmg-installer.sh "https://github.com/Mortennn/Dozer/releases/download/v4.0.0/Dozer.4.0.0.dmg"

# WezTerm - GPU Terminal Emulator
brew install --cask wezterm
# Install WezTerm terminfo for TERM=wezterm
tempfile=$(mktemp) \
  && curl -o $tempfile https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo \
  && tic -x -o ~/.terminfo $tempfile \
  && rm $tempfile
