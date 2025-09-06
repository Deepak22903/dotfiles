#!/bin/bash

# Exit immediately if a command exits with a non-zero status, if an unset variable is used, or if a command in a pipeline fails.
set -euo pipefail

# --- Configuration ---
YAZI_CONFIG_DIR="$HOME/.config/yazi"
YAZI_PLUGINS_DIR="$YAZI_CONFIG_DIR/plugins"

# --- Helper Functions ---

# Ensure Yazi plugins directory exists
setup_yazi_dirs() {
  if [ ! -d "$YAZI_PLUGINS_DIR" ]; then
    echo "🛠️ Creating Yazi plugins directory: $YAZI_PLUGINS_DIR"
    mkdir -p "$YAZI_PLUGINS_DIR"
  else
    echo "✅ Yazi plugins directory already exists: $YAZI_PLUGINS_DIR"
  fi
}

# Installs a Yazi plugin using 'ya pack -a'
# Usage: install_yazi_plugin "plugin_source_string"
# Example: install_yazi_plugin "yazi-rs/plugins:full-border"
install_yazi_plugin() {
  local plugin_source="$1"
  local derived_name
  local plugin_target_dirname

  # Derive base name: part after last '/' then part after last ':'
  # e.g., "imsi32/yatline" -> "yatline"
  # e.g., "yazi-rs/plugins:full-border" -> "full-border"
  derived_name="${plugin_source##*/}"
  derived_name="${derived_name##*:}"

  # Yazi plugins are typically installed into directories ending with ".yazi"
  plugin_target_dirname="$derived_name.yazi"
  local full_plugin_path="$YAZI_PLUGINS_DIR/$plugin_target_dirname"

  if [ -d "$full_plugin_path" ]; then
    echo "✅ Yazi plugin '$derived_name' is already installed at '$full_plugin_path'."
  else
    echo "🧩 Installing Yazi plugin '$derived_name' from '$plugin_source' (target: '$plugin_target_dirname')..."
    if ! command -v ya &>/dev/null; then
      echo "❌ 'ya' command not found. Please ensure Yazi is installed and 'ya' is in your PATH."
      return 1 # Or exit 1 if this is critical
    fi
    ya pack -a "$plugin_source" # This command should handle creating the .yazi directory

    # Verify installation
    if [ -d "$full_plugin_path" ]; then
      echo "👍 Successfully installed '$derived_name' as '$plugin_target_dirname'."
    # Fallback check in case 'ya pack' installed it without the .yazi suffix (less common)
    elif [ -d "$YAZI_PLUGINS_DIR/$derived_name" ]; then
      echo "👍 Successfully installed '$derived_name' as '$derived_name' (Note: .yazi suffix might have been omitted by ya pack)."
      echo "   Standard location would be '$full_plugin_path'."
    else
      echo "⚠️ Failed to install '$derived_name'. Expected directory '$full_plugin_path' or '$YAZI_PLUGINS_DIR/$derived_name' not found."
      echo "   Please check the output of 'ya pack -a \"$plugin_source\"' for errors."
    fi
  fi
}

# Installs a Yazi plugin using 'git clone'
# Usage: install_yazi_plugin_git "repository_url" "target_directory_name"
# Example: install_yazi_plugin_git "https://github.com/user/plugin.yazi.git" "plugin.yazi"
install_yazi_plugin_git() {
  local repo_url="$1"
  local target_dir_name="$2" # This is the exact directory name inside YAZI_PLUGINS_DIR
  local full_plugin_path="$YAZI_PLUGINS_DIR/$target_dir_name"

  if [ -d "$full_plugin_path" ]; then
    echo "✅ Yazi plugin '$target_dir_name' (git) is already installed at '$full_plugin_path'."
  else
    echo "🧩 Installing Yazi plugin '$target_dir_name' from '$repo_url' via git clone..."
    if ! command -v git &>/dev/null; then
      echo "❌ 'git' command not found. Please install git."
      return 1 # Or exit 1
    fi
    git clone "$repo_url" "$full_plugin_path"
    if [ -d "$full_plugin_path" ]; then
      echo "👍 Successfully cloned '$target_dir_name' to '$full_plugin_path'."
    else
      echo "⚠️ Failed to clone '$repo_url' into '$full_plugin_path'."
    fi
  fi
}

# --- Main Script ---
echo "🚀 Starting Yazi plugin setup..."

setup_yazi_dirs

echo ""
echo "--- Installing Yazi Plugins ---"

# catppuccin theme and ui
install_yazi_plugin "imsi32/yatline"
install_yazi_plugin_git "https://github.com/imsi32/yatline-catppuccin.yazi.git" "yatline-catppuccin.yazi"
install_yazi_plugin "yazi-rs/plugins:full-border"

# open with cmd plugin
install_yazi_plugin "Ape/open-with-cmd"

# jump to char plugin
install_yazi_plugin "yazi-rs/plugins:jump-to-char"

# bookmarks plugin
install_yazi_plugin "dedukun/bookmarks"

# chmod plugin
install_yazi_plugin "yazi-rs/plugins:chmod"

# archivemount plugin
install_yazi_plugin "AnirudhG07/archivemount"

# rsync plugin
install_yazi_plugin "GianniBYoung/rsync"

# restore plugin
install_yazi_plugin "boydaihungst/restore"

# simple mtpfs plugin
install_yazi_plugin "boydaihungst/simple-mtpfs"

# copy file contents plugin
install_yazi_plugin "AnirudhG07/plugins-yazi:copy-file-contents"

# toggle-pane plugin
install_yazi_plugin "yazi-rs/plugins:toggle-pane"

# git plugin
install_yazi_plugin "yazi-rs/plugins:git"

# mount management plugin
install_yazi_plugin "yazi-rs/plugins:mount"

# custom-shell plugin
install_yazi_plugin "AnirudhG07/custom-shell"

# compress plugin (uncomment to install)
# echo "--- Optional Plugins (Commented Out) ---"
# install_yazi_plugin "KKV9/compress"

# what-size plugin
install_yazi_plugin "pirafrank/what-size"

# kdeconnect-send plugin
install_yazi_plugin "Deepak22903/kdeconnect-send"

echo ""
echo "🎉 Yazi plugin setup finished."
