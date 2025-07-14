#!/bin/bash

# Exit immediately if a command exits with a non-zero status, if an unset variable is used, or if a command in a pipeline fails.
set -euo pipefail

# --- Colors ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'

# --- Helper Functions ---
info() {
  echo -e "${C_CYAN}INFO:${C_RESET} $1"
}

success() {
  echo -e "${C_GREEN}✅ SUCCESS:${C_RESET} $1"
}

warn() {
  echo -e "${C_YELLOW}⚠️ WARNING:${C_RESET} $1"
}

error() {
  echo -e "${C_RED}❌ ERROR:${C_RESET} $1" >&2
  exit 1
}

check_pkg_installed() {
  pacman -Q "$1" &>/dev/null
}

check_yay_pkg_installed() {
  yay -Q "$1" &>/dev/null
}

check_command_exists() {
  command -v "$1" &>/dev/null
}

# --- Main Functions ---

system_update() {
  info "Updating system packages..."
  sudo pacman -Syu --noconfirm
  success "System packages updated."
}

install_nerd_fonts() {
  info "Installing Nerd Fonts..."
  # Assuming install_nerd_font.sh is in the parent directory of this script's location
  local script_dir
  script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
  if [ -f "$script_dir/../install_nerd_font.sh" ]; then
    source "$script_dir/../install_nerd_font.sh"
    success "Nerd Fonts installation script executed."
  else
    warn "install_nerd_font.sh not found, skipping Nerd Font installation."
  fi
}

install_yay() {
  if check_command_exists yay; then
    success "yay is already installed."
    return
  fi

  info "Installing yay (AUR Helper)..."
  if ! check_pkg_installed git || ! check_pkg_installed base-devel; then
    info "Installing prerequisites for yay: git and base-devel..."
    sudo pacman -S --needed --noconfirm git base-devel
  fi

  local temp_dir
  temp_dir=$(mktemp -d)
  info "Cloning yay-bin into temporary directory: $temp_dir"
  git clone https://aur.archlinux.org/yay-bin.git "$temp_dir"
  (
    cd "$temp_dir" || exit 1
    info "Building and installing yay..."
    makepkg -si --noconfirm
  )
  info "Cleaning up temporary yay directory: $temp_dir"
  rm -rf "$temp_dir"

  if check_command_exists yay; then
    success "yay installed successfully!"
  else
    error "Failed to install yay."
  fi
}

install_packages() {
  info "Installing packages..."
  local packages_file="$1"
  local aur_packages=(
    "yazi"
    "bat"
    "tldr"
    "ani-cli"
    "eza"
    "linux-wifi-hotspot"
    "zoxide"
    "yt-dlp"
    "tty-clock"
    "sshfs"
    "python-pipx"
    "fzf"
    "tmux"
    "shell-color-scripts-git"
    "wl-clipboard"
    "rofi-wayland"
    "copyq"
    "beautyline"
    "firefox"
  )
  local pacman_packages=(
    "nlohmann-json"
    "ghq"
    "stow"
    "bluez"
    "bluez-utils"
    "blueman"
  )

  # Install packages from file
  if [ -f "$packages_file" ]; then
    info "Installing packages from $packages_file..."
    yay -S --needed --noconfirm - < "$packages_file"
    success "All packages from list processed."
  else
    warn "$packages_file not found. Skipping package installation from list."
  fi

  # Install other packages
  info "Installing additional pacman packages..."
  sudo pacman -S --needed --noconfirm "${pacman_packages[@]}"
  
  info "Installing additional AUR packages..."
  yay -S --needed --noconfirm "${aur_packages[@]}"

  success "All packages installed."
}

setup_kanata() {
  info "Setting up Kanata..."
  if ! check_command_exists cargo; then
    info "Rust (cargo) is not installed. Installing Rust via rustup..."
    if ! check_command_exists rustup; then
      sudo pacman -S --needed --noconfirm rustup
    fi
    rustup install stable
    rustup default stable
  fi

  if ! check_command_exists kanata; then
    info "Installing Kanata..."
    cargo install kanata
    if [ -f "$HOME/.cargo/bin/kanata" ]; then
      info "Copying kanata to /usr/local/bin..."
      sudo cp "$HOME/.cargo/bin/kanata" /usr/local/bin/
    else
      error "Kanata binary not found in $HOME/.cargo/bin after installation."
    fi
  fi

  local service_file="./configFiles/kanata.service"
  if [ -f "$service_file" ]; then
    if [ ! -f "/etc/systemd/system/kanata.service" ]; then
      info "Copying kanata.service to /etc/systemd/system..."
      sudo cp "$service_file" /etc/systemd/system/
      sudo systemctl daemon-reload
    fi
    if ! sudo systemctl is-enabled kanata.service &>/dev/null; then
      info "Enabling kanata.service..."
      sudo systemctl enable kanata.service
    fi
    if ! sudo systemctl is-active kanata.service &>/dev/null; then
      info "Starting kanata.service..."
      sudo systemctl start kanata.service
    fi
    success "Kanata service is set up and running."
  else
    warn "$service_file not found. Skipping Kanata service setup."
  fi
}

setup_custom_scripts() {
  info "Setting up custom scripts..."
  local source_repo="Deepak22903/My_Shell_Scripts"
  local source_dir="$HOME/ghq/github.com/$source_repo"

  if [ ! -d "$source_dir" ]; then
    info "Cloning $source_repo using ghq..."
    ghq get "$source_repo"
  else
    info "Source directory for custom scripts already exists: $source_dir"
    info "Consider running 'ghq get -u $source_repo' manually to update."
  fi

  # Screen Utility
  local screen_util_target="/usr/local/bin/screen_controller"
  local screen_util_source="$source_dir/cpp/screen_idle_controller/screen_idle_controller.cpp"
  if [ ! -f "$screen_util_target" ]; then
    if [ -f "$screen_util_source" ]; then
      info "Compiling screen_idle_controller.cpp..."
      local temp_build_dir
      temp_build_dir=$(mktemp -d)
      g++ "$screen_util_source" -o "$temp_build_dir/screen_controller"
      info "Moving compiled screen_controller to $screen_util_target..."
      sudo mv "$temp_build_dir/screen_controller" "$screen_util_target"
      rm -rf "$temp_build_dir"
      success "Screen utility compiled and moved to $screen_util_target."
    else
      warn "$screen_util_source not found. Cannot compile screen utility."
    fi
  else
    success "Screen utility ($screen_util_target) already exists."
  fi

  # Firefox Config Utility
  local firefox_config_target="/usr/local/bin/firefox_config"
  local firefox_config_source="$source_dir/global/firefox_config"
  if [ ! -f "$firefox_config_target" ]; then
    if [ -f "$firefox_config_source" ]; then
      info "Copying firefox_config to $firefox_config_target..."
      sudo cp "$firefox_config_source" "$firefox_config_target"
      sudo chmod +x "$firefox_config_target"
      success "Firefox config utility copied to $firefox_config_target."
    else
      warn "$firefox_config_source not found. Cannot set up Firefox config utility."
    fi
  else
    success "Firefox config utility ($firefox_config_target) already exists."
  fi
}

setup_nvim() {
  info "Setting up Neovim with LazyVim starter..."
  if [ -d "$HOME/.config/nvim" ]; then
    info "Backing up existing nvim config to ~/.config/nvim.bak"
    mv ~/.config/nvim{,.bak}
  fi
  
  # Optional backups
  [ -d "$HOME/.local/share/nvim" ] && mv ~/.local/share/nvim{,.bak}
  [ -d "$HOME/.local/state/nvim" ] && mv ~/.local/state/nvim{,.bak}
  [ -d "$HOME/.cache/nvim" ] && mv ~/.cache/nvim{,.bak}

  info "Cloning LazyVim starter..."
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  info "Stowing custom nvim configuration..."
  rm -f ~/.config/nvim/init.lua
  rm -rf ~/.config/nvim/lua
  stow --dir="$HOME/dotfiles" --target="$HOME" --adopt nvim
  success "Neovim setup complete."
}

setup_fish_shell() {
  info "Setting up Fish shell..."
  yay -S --needed --noconfirm fish

  info "Installing Tide prompt for Fish..."
  local temp_dir
  temp_dir=$(mktemp -d)
  curl -sL https://codeload.github.com/ilancosman/tide/tar.gz/v6 | tar -xzC "$temp_dir"
  # This assumes a standard fish config location.
  command cp -R "$temp_dir"/tide-v6/{completions,conf.d,functions} "$HOME/.config/fish/"
  rm -rf "$temp_dir"
  
  info "Stowing fish configuration..."
  stow --dir="$HOME/dotfiles" --target="$HOME" fish

  info "Setting fish theme to Catppuccin Mocha..."
  # Run this command as the user, not root
  fish -c "fish_config theme save 'Catppuccin Mocha'"
  
  success "Fish shell setup complete."
}

setup_bluetooth() {
  info "Setting up Bluetooth..."
  sudo systemctl enable bluetooth.service
  sudo systemctl start bluetooth.service
  success "Bluetooth service enabled and started."
}

setup_tmux() {
  info "Setting up Tmux..."
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Cloning Tmux Plugin Manager (tpm)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi
  
  info "Stowing tmux configuration..."
  stow --dir="$HOME/dotfiles" --target="$HOME" tmux
  
  success "Tmux setup complete."
  info "If tmux is running, reload config with: tmux source ~/.config/tmux/tmux.conf"
  info "Then press prefix(Ctrl+a) + I to install plugins."
}

stow_configs() {
  info "Stowing dotfiles..."
  local configs_to_stow=(
    "hyprland"
    "kitty"
    "yazi"
    "waybar"
    "lazygit"
    "swaync"
    "mimeapps"
    "qimgv"
    "zathura"
  )

  # Special handling for files that might exist
  rm -f ~/.config/hypr/hyprland.conf
  rm -f ~/.config/lazygit/config.yml
  rm -f ~/.config/mimeapps.list
  rm -rf ~/.config/qimgv

  for config in "${configs_to_stow[@]}"; do
    info "Stowing $config..."
    stow --dir="$HOME/dotfiles" --target="$HOME" "$config"
  done
  success "Dotfiles stowed."
}

setup_sddm_theme() {
  info "Setting up SDDM theme..."
  local temp_dir="/tmp/sddmTheme"
  git clone https://github.com/stepanzubkov/where-is-my-sddm-theme.git "$temp_dir"
  sudo "$temp_dir/install.sh" current
  sudo cp "$HOME/dotfiles/instalScripts/configFiles/sddmTheme.conf" /usr/share/sddm/themes/where_is_my_sddm_theme/theme.conf
  rm -rf "$temp_dir"
  success "SDDM theme installed."
}

main() {
  system_update
  install_nerd_fonts
  install_yay
  
  local script_dir
  script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
  install_packages "$script_dir/../../package_list_new.txt"
  
  setup_kanata
  setup_custom_scripts
  setup_nvim
  setup_fish_shell
  setup_bluetooth
  setup_tmux
  stow_configs
  setup_sddm_theme

  # Source yazi configuration
  local yazi_config_script="./configFiles/yazi.sh"
  if [ -f "$yazi_config_script" ]; then
    info "Sourcing yazi.sh configuration..."
    # shellcheck source=./configFiles/yazi.sh
    source "$yazi_config_script"
  else
    warn "$yazi_config_script not found. Skipping yazi configuration."
  fi

  success "🎉 System setup script finished successfully!"
  info "Some changes might require a logout or reboot to take effect."
}

# --- Execute Script ---
main

