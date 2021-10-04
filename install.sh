#!/bin/sh

if [ "$(whoami)" != "root" ]; then
    echo "Please run as root using sudo"
    exit
fi

chmod u+x bashnotes
sudo cp bashnotes /usr/bin/
echo "BashNotes is succesfully installed"
