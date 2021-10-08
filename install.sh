#!/bin/sh

if [ "$(whoami)" != "root" ]; then
    echo "Please run as root using sudo"
    exit
fi

echo "Installing BashNotes"

wget https://raw.githubusercontent.com/qewer33/BashNotes/main/bashnotes

chmod u+x bashnotes.bash
sudo mv bashnotes.sh /usr/bin/bashnotes && echo "BashNotes is succesfully installed"
