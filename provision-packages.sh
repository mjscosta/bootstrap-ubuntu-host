#!/bin/bash
# @autor Mário Costa
# @date 16/10/2018

# output commands to console
set -x
set -v

function add_key_from_url() {
# Fetches the list of keys from the list of urls and adds them via apt-key 
# params - list of urls to fetch and add the key
  while [ $# -gt 0 ]
  do
    # curl -fsSL $1 | apt-key add -
    wget -q $1 -O- | apt-key add -
    shift
  done
}

function add_sources_list() {
# Creates a sources list file in /etc/apt/sources.list.d/
# param 1 - the file prefix
# param 2... - list of entries to add to the file
  sources_file=/etc/apt/sources.list.d/$1.list
  # truncate file
  : > $sources_file
  shift

  while [ $# -gt 0 ]
  do
    echo $1 >> $sources_file
    shift
  done
}

DOWNLOAD_DIR=/tmp/
# PACKAGES_DELAYED_INSTALL # use this variable to update and install all packages at once.


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# Ubunto apt packages
# System packages

PACKAGES_DELAYED_INSTALL+=(apt-transport-https ca-certificates software-properties-common)

# python templating jinja2
PACKAGES_DELAYED_INSTALL+=(python-jinja2)


# development
PACKAGES_DELAYED_INSTALL+=(vim git meld zeal)

# configure vim default difftool and editor for meld and vim.
# this must be done under user not root/sudo. 

# --------------- Communication Tools --------------
# snap install slack --classic

# --------------- PYTHON ---------------------------
# python ide
snap install pycharm-community --classic

#--------------- C++ -------------------------------
#C++ ide
PACKAGES_DELAYED_INSTALL+=(qtcreator)


# ---- VIRTUAL BOX ---
VBOX_KEY_PREFIX=https://www.virtualbox.org/download/
VBOX_KEY1=oracle_vbox_2016.asc
VBOX_KEY2=oracle_vbox.asc

add_key_from_url ${VBOX_KEY_PREFIX}${VBOX_KEY1} ${VBOX_KEY_PREFIX}${VBOX_KEY2}

VBOX_VER=5.2
VBOX_NAME=virtualbox

add_sources_list $VBOX_NAME-$VBOX_VER "deb https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
    
PACKAGES_DELAYED_INSTALL+=(virtualbox-5.2)

# ---- VAGRANT ---------
VAGRANT_VER=2.1.5
VAGRANT_DEB_URL="https://releases.hashicorp.com/vagrant/$VAGRANT_VER/vagrant_${VAGRANT_VER}_x86_64.deb"

# check if installed, avoid downloading again, allow to execute more than once without breaking.
read VAGRANT_STATUS[{1..2}] <<< $(dpkg -l vagrant | grep ii | cut -d ' ' --fields="1 3")

# if not installed, download and install
if [ "${VAGRANT_STATUS[1]}" != "ii" ]; then
  wget -q -P $DOWNLOAD_DIR $VAGRANT_DEB_URL -O ${DOWNLOAD_DIR}vagrant_${VAGRANT_VER}_x86_64.deb

  # verify checksum, if there's an error exit
  echo "458b1804b61443cc39ce1fe9ef9aca53c403f25c36f98d0f15e1b284f2bddb65 ${DOWNLOAD_DIR}vagrant_${VAGRANT_VER}_x86_64.deb" \
  | sha256sum --check || { rm ${DOWNLOAD_DIR}vagrant_${VAGRANT_VER}_x86_64.deb ; echo "Error downloading $VAGRANT_DEB_URL."; exit 1; } 

  dpkg -i ${DOWNLOAD_DIR}vagrant_${VAGRANT_VER}_x86_64.deb
  rm ${DOWNLOAD_DIR}vagrant_${VAGRANT_VER}_x86_64.deb
fi

# ---- DOCKER ----------
#DOCKER_VER=
DOCKER_NAME=docker

add_key_from_url https://download.docker.com/linux/ubuntu/gpg
add_sources_list $DOCKER_NAME "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

PACKAGES_DELAYED_INSTALL+=(docker-ce)

# install all packages

apt-get update
apt-get install -y ${PACKAGES_DELAYED_INSTALL[@]}


