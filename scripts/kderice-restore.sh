#!/bin/bash

export PATH=$PATH:~/.local/bin
cp -r $HOME/$SCRIPTHOME/config/.config/* $HOME/.config/
pip install konsave
konsave -i $HOME/$SCRIPTHOME/config/kde.knsv
sleep 1
konsave -a kde
