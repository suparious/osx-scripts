#!/bin/bash

# Termux on Android 8 (Oreo)+
DATE=$(date +"%Y-%m-%d")
HOME="/data/data/com.termux/files/home"
DATA="/sdcard/Download"

cd $DATA
tar czvf backup-$DATE.tar.gz $HOME
cd $HOME
