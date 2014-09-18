#!/bin/bash

DEV="$HOME/Development"
DOTFILES="$HOME/dotfiles"
BIN="/usr/local/bin"

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &



## set hostname of machine

echo 'Enter new hostname of the machine (e.g. aegus)'
  read HOSTNAME
  sudo scutil --set HostName "$HOSTNAME"
  COMPNAME=$(sudo scutil --get HostName | tr '-' '.')
  sudo scutil --set ComputerName "$COMPNAME"
  sudo scutil --set LocalHostName "$COMPNAME"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPNAME"





## install brew

source "$HOME/.bashrc"

if ! which brew &> /dev/null; then
    echo "Installing homebrew"
    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
fi

## install brew bundle

brew bundle $DOTFILES/osx/Brewfile

## OR

# If we on OS X, install homebrew and tweak system a bit.
if [[ `uname` == 'Darwin' ]]; then
  which -s brew
  if [[ $? != 0 ]]; then
    echo 'Installing Homebrew...'
      ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
      brew update
      brew bundle $DOTFILES/osx/Brewfile
  fi

  echo 'Tweaking OS X...'
    source $DOTFILES/osx/Brewfileosx.sh
fi


## github ssh

echo 'Checking for SSH key, generating one if it does not exist...'
  [[ -f '~/.ssh/id_rsa.pub' ]] || ssh-keygen -t rsa

echo 'Copying public key to clipboard. Paste it into your Github account...'
  [[ -f '~/.ssh/id_rsa.pub' ]] && cat '~/.ssh/id_rsa.pub' | pbcopy
  open 'https://github.com/account/ssh'

## sublime settings

if [[ `uname` == 'Darwin' ]]; then
  link "$dotfiles/sublime/Packages/User/Preferences.sublime-settings" "$HOME/Library/Application Support/Sublime Text 2/Packages/User/Preferences.sublime-settings"
fi


## Install Menlo-ForPowerline Font
wget --directory-prefix=$HOME/Downloads/ https://gist.github.com/raw/1627888/c4e92f81f7956d4ceaee11b5a7b4c445f786dd90/Menlo-ForPowerline.ttc.zip
unzip ~/Downloads/Menlo-ForPowerline.ttc.zip -d ~/Downloads
cp ~/Downloads/Menlo-ForPowerline.ttc /Library/Fonts

# Use black and white menu bar icons” setting for Dropbox
for p in /Applications/Dropbox.app/Contents/Resources/*-lep.tiff; do echo cp $p ${p%-lep.tiff}.tiff; done


# exclude directories from Time Machine backups
tmutil addexclusion ~/Downloads
tmutil addexclusion ~/Movies

# Terminal
# ========

# Use a modified version of the Pro theme by default in Terminal.app
open "$HOME/.dotfiles/osxterminal/christophera-light.terminal"
sleep 1 # Wait a bit to make sure the theme is loaded
open "$HOME/.dotfiles/osxterminal/christophera-dark.terminal"
sleep 1 # Wait a bit to make sure the theme is loaded
defaults write com.apple.terminal 'Default Window Settings' -string 'christophera-dark'
defaults write com.apple.terminal 'Startup Window Settings' -string 'christophera-dark'

### update Mac OSX's nano
### as per https://github.com/Homebrew/homebrew-dupes
### also updates curses
brew tap homebrew/dupes
brew install nano







# Symlink sublime user settings
SUBLIME_PACKAGES="$HOME/Library/Application Support/Sublime Text 3/Packages"
SUBLIME_USER_SETTINGS="$SUBLIME_PACKAGES/User"
mkdir -p "$SUBLIME_PACKAGES"
rm -rf "$SUBLIME_USER_SETTINGS"
ln -s $HOME/.sublime "$SUBLIME_USER_SETTINGS"

# Update sublime
sublimeup
# Pressing keys should repeat and not stop
defaults write com.sublimetext.3 ApplePressAndHoldEnabled -bool false

# MultimarkDown Quicklook
cd ~/Downloads
git clone https://github.com/oschrenk/MMD-QuickLook
cd MMD-QuickLook
make compile
make install
qlmanage -r



# Restart automatically if the computer freezes
systemsetup -setrestartfreeze on

# Enable fast user switching
defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool YES