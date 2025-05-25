#!/bin/bash

# catppuccin theme and ui
ya pack -a imsi32/yatline
git clone https://github.com/imsi32/yatline-catppuccin.yazi.git ~/.config/yazi/plugins/yatline-catppuccin.yazi
ya pack -a yazi-rs/plugins:full-border

# open with cmd plugin
ya pack -a Ape/open-with-cmd

# jump to char plugin
ya pack -a yazi-rs/plugins:jump-to-char

# bookmarks plugin
ya pack -a dedukun/bookmarks

# chmod plugin
ya pack -a yazi-rs/plugins:chmod

# archivemount plugin
ya pack -a AnirudhG07/archivemount

# rsync plugin
ya pack -a GianniBYoung/rsync

# restore plugin
ya pack -a boydaihungst/restore

# simple mtpfs plugin
ya pack -a boydaihungst/simple-mtpfs

# copy file contents plugin
ya pack -a AnirudhG07/plugins-yazi:copy-file-contents

# toggle-pane plugin
ya pack -a yazi-rs/plugins:toggle-pane

# git plugin
ya pack -a yazi-rs/plugins:git

# mount management plugin
ya pack -a yazi-rs/plugins:mount

# custom-shell plugin
ya pack -a AnirudhG07/custom-shell

# compress plugin
# ya pack -a KKV9/compress

# what-size plugin
ya pack -a pirafrank/what-size

# kdeconnect-send plugin
ya pack -a Deepak22903/kdeconnect-send
