#!/bin/bash
# @autor Mário Costa
# @date 17/10/2018

# output commands to console
set -x
set -v


# Add user to groups

usermod -a -G development $USER

# Create ssh keys

mkdir -p $HOME/.ssh
cd $HOME/.ssh

# Generate passphrase for sshkey-gen
# https://www.howtogeek.com/howto/30184/10-ways-to-generate-a-random-password-from-the-command-line/
tr -cd '[:alnum:]|!"#$%&/\()?;,:..<>+-' < /dev/urandom | fold -w12 | head -n1 > $HOME/.ssh/passphrase && chmod 400 $HOME/.ssh/passphrase
echo "Please store the passphrase in a safe place, and delete it from the filesystem."


# Secure key
# https://security.stackexchange.com/questions/143442/what-are-ssh-keygen-best-practices
# add a passphrase and use ssh-agent to avoid inputing it all the time
ssh-keygen -t rsa -b 4096 -o -a 100 -q -N $(cat $HOME/.ssh/passphrase) -f $HOME/.ssh/id_rsa

# Provision user custom settings

# Set Nautilus default view to List-View
# https://askubuntu.com/questions/134371/how-do-i-set-default-view-to-list-in-nautilus-file-manager
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'


# Set local window menus
# https://askubuntu.com/questions/10481/how-do-i-enable-or-disable-the-global-application-menu
gsettings set com.canonical.Unity integrated-menus true
gsettings set  com.canonical.Unity always-show-menus true
