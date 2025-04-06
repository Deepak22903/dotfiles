#!/bin/bash

sudo pacman -Syu

# Function to check if yay is installed
if command -v yay &>/dev/null; then
  echo "Yay is already installed."
else
  echo "Yay is not installed. Installing yay..."

  # Install yay (assuming base-devel and git are installed)
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin || exit
  makepkg -si --noconfirm
  cd ..
  rm -rf yay-bin

  # Verify installation
  if command -v yay &>/dev/null; then
    echo "Yay installed successfully!"
  else
    echo "Failed to install Yay. Please check for errors."
  fi
fi

# Install packages
yay -Syu
yay -S --noconfirm - <package_list_new.txt

# Install kanata
sudo pacman -S rustup
rustup install stable
rustup default stable
cargo install kanata
sudo cp .cargo/bin/kanata /bin
sudo cp ./configFiles/kanata.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable kanata.service
sudo systemctl start kanata.service
source ./configFiles/yazi.sh
