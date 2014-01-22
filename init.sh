#!/bin/bash

# usage : source init.sh


chmod +x *.sh

# the content of this file after this comment should be copied at the end
# of your ~/.profile or ~./bashrc file 
# TODO automate this, end make aliases

# the trash
mkdir -p $HOME/.Trash
export TRASH=$HOME/.Trash

# the record file
touch ${HOME}/.trashrec
export RECORD=${HOME}/.trashrec


 
