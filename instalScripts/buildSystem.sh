#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Helper Functions ---
check_pkg_installed() {
  if pacman -Q "$1" &>/dev/null; then
    echo "✅ $1 is already installed."
    return 0 # 0 indicates true (installed)
  else
    return 1 # 1 indicates false (not installed)
  fi
}

check_yay_pkg_installed() {
  if yay -Q "$1" &>/dev/null; then
    echo "✅ $1 is already installed (via yay/AUR)."
    return 0
  else
    return 1
  fi
}

check_command_exists() {
  if command -v "$1" &>/dev/null; then
    echo "✅ Command '$1' is available."
    return 0
  else
    echo "⚠️ Command '$1' not found."
    return 1
  fi
}

# --- System Update ---
echo "🔄 Updating system packages..."
sudo pacman -Syu --noconfirm

source ../install_nerd_font.sh

# --- Install yay (AUR Helper) ---
if check_command_exists yay; then
  echo "🎉 Yay is already installed."
else
  echo "🛠️ Yay is not installed. Installing yay..."
  if ! check_pkg_installed git || ! check_pkg_installed base-devel; then
    echo "Installing prerequisites for yay: git and base-devel..."
    sudo pacman -S --needed --noconfirm git base-devel
  else
    echo "Prerequisites for yay (git, base-devel) are already satisfied."
  fi

  # Create a temporary directory for cloning and building yay
  TEMP_YAY_DIR=$(mktemp -d)
  echo "Cloning yay-bin into temporary directory: $TEMP_YAY_DIR"
  git clone https://aur.archlinux.org/yay-bin.git "$TEMP_YAY_DIR"
  ( # Start a subshell to avoid `cd` issues
    cd "$TEMP_YAY_DIR" || {
      echo "❌ Failed to change directory to $TEMP_YAY_DIR"
      exit 1
    }
    echo "Building and installing yay..."
    makepkg -si --noconfirm
  )
  echo "Cleaning up temporary yay directory: $TEMP_YAY_DIR"
  rm -rf "$TEMP_YAY_DIR"

  if check_command_exists yay; then
    echo "🎉 Yay installed successfully!"
  else
    echo "❌ Failed to install Yay. Please check for errors."
    exit 1 # Exit if yay installation failed, as it's crucial for next steps
  fi
fi

# --- Install Packages from List ---
echo "📦 Installing packages from package_list_new.txt..."
if [ -f "package_list_new.txt" ]; then
  # Update AUR packages first
  yay -Syu --noconfirm --aur

  # Read package_list_new.txt and install packages
  # This loop checks each package before attempting to install
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    if [[ -z "$pkg" ]] || [[ "$pkg" =~ ^# ]]; then # Skip empty lines and comments
      continue
    fi
    if ! yay -Q "$pkg" &>/dev/null; then
      echo "Installing $pkg..."
      yay -S --needed --noconfirm "$pkg"
    else
      echo "✅ $pkg is already installed."
    fi
  done <"package_list_new.txt"
  echo "✅ All packages from list processed."
else
  echo "⚠️ package_list_new.txt not found. Skipping package installation from list."
fi

# --- Install and Setup Kanata ---
echo "⌨️ Setting up Kanata..."
if ! check_command_exists cargo; then
  echo "Rust (cargo) is not installed. Installing Rust via rustup..."
  if ! check_command_exists rustup; then
    sudo pacman -S --needed --noconfirm rustup
  else
    echo "✅ rustup is already installed."
  fi
  rustup install stable
  rustup default stable
else
  echo "✅ Rust (cargo) is already installed."
  # Ensure stable toolchain is default if rustup is managed elsewhere
  if check_command_exists rustup; then
    if ! rustup show active-toolchain | grep -q "stable"; then
      echo "Setting rustup default toolchain to stable..."
      rustup default stable
    else
      echo "✅ Rust stable toolchain is already active."
    fi
  fi
fi

if ! check_command_exists kanata; then
  echo "Installing Kanata..."
  cargo install kanata
  if [ -f "$HOME/.cargo/bin/kanata" ]; then
    echo "Copying kanata to /usr/local/bin..." # Changed from /bin to /usr/local/bin as per FHS
    sudo cp "$HOME/.cargo/bin/kanata" /usr/local/bin/
    sudo cp "$HOME/.cargo/bin/kanata" /usr/bin/
    sudo cp "$HOME/.cargo/bin/kanata" /bin/
  else
    echo "❌ Kanata binary not found in $HOME/.cargo/bin after installation."
    echo "Please ensure cargo install kanata completed successfully and ~/.cargo/bin is in your PATH for the current user."
  fi
else
  echo "✅ Kanata is already installed and accessible in PATH."
fi

if [ -f "./configFiles/kanata.service" ]; then
  if [ ! -f "/etc/systemd/system/kanata.service" ]; then
    echo "Copying kanata.service to /etc/systemd/system..."
    sudo cp ./configFiles/kanata.service /etc/systemd/system/
    sudo systemctl daemon-reload
  else
    echo "✅ kanata.service already exists in /etc/systemd/system."
  fi

  if ! sudo systemctl is-enabled kanata.service &>/dev/null; then
    echo "Enabling kanata.service..."
    sudo systemctl enable kanata.service
  else
    echo "✅ kanata.service is already enabled."
  fi

  if ! sudo systemctl is-active kanata.service &>/dev/null; then
    echo "Starting kanata.service..."
    sudo systemctl start kanata.service
  else
    echo "✅ kanata.service is already active."
  fi
else
  echo "⚠️ ./configFiles/kanata.service not found. Skipping Kanata service setup."
fi

yay -S yazi

# Source yazi configuration (assuming it sets environment variables or aliases)
if [ -f "./configFiles/yazi.sh" ]; then
  echo "⚙️ Sourcing yazi.sh configuration..."
  # shellcheck source=./configFiles/yazi.sh
  source ./configFiles/yazi.sh
else
  echo "⚠️ ./configFiles/yazi.sh not found. Skipping yazi configuration."
fi

# --- Install nlohmann-json ---
echo "📦 Installing nlohmann-json..."
if ! check_pkg_installed nlohmann-json; then
  sudo pacman -S --needed --noconfirm nlohmann-json
else
  echo "✅ nlohmann-json is already installed."
fi

# --- Setting up Screen Utility ---
echo "🖥️ Setting up screen utility..."
SCREEN_UTIL_TARGET="/usr/local/bin/screen_controller" # Renamed for clarity and FHS compliance
SCREEN_UTIL_SOURCE_DIR="$HOME/ghq/github.com/Deepak22903/My_Shell_Scripts"
SCREEN_UTIL_CPP_FILE="$SCREEN_UTIL_SOURCE_DIR/cpp/screen_idle_controller/screen_idle_controller.cpp"

if [ ! -f "$SCREEN_UTIL_TARGET" ]; then
  if ! check_command_exists ghq; then
    echo "⚠️ ghq is not installed. Please install it to clone repositories (e.g., yay -S ghq)."
  else
    if [ ! -d "$SCREEN_UTIL_SOURCE_DIR" ]; then
      echo "Cloning Deepak22903/My_Shell_Scripts using ghq..."
      ghq get Deepak22903/My_Shell_Scripts # 'ghq get' is idempotent
    else
      echo "✅ Source directory for screen utility already exists: $SCREEN_UTIL_SOURCE_DIR"
      echo "Consider running 'ghq get -u Deepak22903/My_Shell_Scripts' manually to update."
    fi

    if [ -f "$SCREEN_UTIL_CPP_FILE" ]; then
      echo "Compiling screen_idle_controller.cpp..."
      TEMP_BUILD_DIR=$(mktemp -d)
      g++ "$SCREEN_UTIL_CPP_FILE" -o "$TEMP_BUILD_DIR/screen_controller"
      echo "Moving compiled screen_controller to $SCREEN_UTIL_TARGET..."
      sudo mv "$TEMP_BUILD_DIR/screen_controller" "$SCREEN_UTIL_TARGET"
      rm -rf "$TEMP_BUILD_DIR" # Clean up temporary build directory
      echo "✅ Screen utility compiled and moved to $SCREEN_UTIL_TARGET."
    else
      echo "❌ $SCREEN_UTIL_CPP_FILE not found. Cannot compile screen utility."
    fi
  fi
else
  echo "✅ Screen utility ($SCREEN_UTIL_TARGET) already exists."
fi

# --- Setting up Firefox Config Utility ---
echo "🦊 Setting up Firefox config utility..."
FIREFOX_CONFIG_TARGET="/usr/local/bin/firefox_config" # FHS compliance
FIREFOX_CONFIG_SOURCE_DIR="$HOME/ghq/github.com/Deepak22903/My_Shell_Scripts"
FIREFOX_CONFIG_SOURCE_FILE="$FIREFOX_CONFIG_SOURCE_DIR/global/firefox_config"

if [ ! -f "$FIREFOX_CONFIG_TARGET" ]; then
  if ! check_command_exists ghq; then
    echo "⚠️ ghq is not installed. Please install it to clone repositories (e.g., yay -S ghq)."
  else
    if [ ! -d "$FIREFOX_CONFIG_SOURCE_DIR" ]; then
      echo "Cloning Deepak22903/My_Shell_Scripts using ghq..."
      ghq get Deepak22903/My_Shell_Scripts
    else
      echo "✅ Source directory for Firefox config utility already exists: $FIREFOX_CONFIG_SOURCE_DIR"
      echo "Consider running 'ghq get -u Deepak22903/My_Shell_Scripts' manually to update."
    fi

    if [ -f "$FIREFOX_CONFIG_SOURCE_FILE" ]; then
      echo "Copying firefox_config to $FIREFOX_CONFIG_TARGET..."
      sudo cp "$FIREFOX_CONFIG_SOURCE_FILE" "$FIREFOX_CONFIG_TARGET"
      sudo chmod +x "$FIREFOX_CONFIG_TARGET" # Ensure it's executable
      echo "✅ Firefox config utility copied to $FIREFOX_CONFIG_TARGET."
    else
      echo "❌ $FIREFOX_CONFIG_SOURCE_FILE not found. Cannot set up Firefox config utility."
    fi
  fi
else
  echo "✅ Firefox config utility ($FIREFOX_CONFIG_TARGET) already exists."
fi

echo "🎉 Script finished."

# Remove hyprland.conf and then show hyprland
rm ~/.config/hypr/hyprland.conf
stow hyprland
# Change the monitor name in hyprland.conf, check monitor name using hyprctl monitors
yay -S firefox

# install lazyvim
# required
mv ~/.config/nvim{,.bak}

# optional but recommended
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

git clone https://github.com/LazyVim/starter ~/.config/nvim

rm -rf ~/.config/nvim/.git

# remove init.lua and lua directory in ~/.config/nvim/ , then stow --adopt nvim
rm ~/.config/nvim/init.lua
rm -r ~/.config/nvim/lua
stow --adopt nvim

yay -S fish
fish

# stow kitty directly
stow kitty

# setup bluetooth
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# install tide prompt
set -l _tide_tmp_dir (command mktemp -d)
curl https://codeload.github.com/ilancosman/tide/tar.gz/v6 | tar -xzC $_tide_tmp_dir
command cp -R $_tide_tmp_dir/*/{completions,conf.d,functions} $__fish_config_dir
fish_path=(status fish-path) exec $fish_path -C "emit _tide_init_install"

yay -S bat tldr ani-cli eza linux-wifi-hotspot zoxide yt-dlp tty-clock sshfs python-pipx fzf tmux shell-color-scripts  wl-clipboard rofi-wayland

