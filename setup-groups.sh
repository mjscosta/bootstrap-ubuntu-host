#!/bin/bash
# @autor Mário Costa
# @date 17/10/2018

# output commands to console
set -x
set -v
groupadd development
# use a /data directory where I add development stuff, this directory is under dev group
mkdir -p /data/develpment/projects/
chown -R :development /data/


