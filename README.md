# My dotfiles

This directory contains the dotfiles for my system

## Requirements

Ensure you have the following installed on your system

### Git

```
pacman -S git
```

### Stow

```
pacman -S stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
 git clone https://github.com/Deepak22903/dotfiles.git
 cd dotfiles
```

then use GNU stow to create symlinks

```
 stow <name of available directory>

```

## Install Kanata keyboard remapper

- Windows

```bash
wget https://github.com/jtroo/kanata/releases/download/v1.8.1/kanata.exe
wget https://raw.githubusercontent.com/Deepak22903/dotfiles/refs/heads/main/kanata.kbd
kanata.exe -c kanata.kbd
```

- Linux

```bash
wget https://github.com/jtroo/kanata/releases/download/v1.8.1/kanata
wget https://raw.githubusercontent.com/Deepak22903/dotfiles/refs/heads/main/kanata.kbd
sudo kanata.exe -c kanata.kbd
```
