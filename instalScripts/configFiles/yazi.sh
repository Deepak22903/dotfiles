#!/bin/bash
set -euo pipefail

# --- Configuration ---
YAZI_CONFIG_DIR="$HOME/.config/yazi"
YAZI_PLUGINS_DIR="$YAZI_CONFIG_DIR/plugins"

# --- Helper Functions ---

setup_yazi_dirs() {
  if [ ! -d "$YAZI_PLUGINS_DIR" ]; then
    echo "🛠️ Creating Yazi plugins directory: $YAZI_PLUGINS_DIR"
    mkdir -p "$YAZI_PLUGINS_DIR"
  else
    echo "✅ Yazi plugins directory already exists: $YAZI_PLUGINS_DIR"
  fi
}

# Install via new `ya pkg add`
install_yazi_plugin() {
  local plugin_source="$1"
  local derived_name
  local plugin_target_dirname

  derived_name="${plugin_source##*/}"
  derived_name="${derived_name##*:}"
  plugin_target_dirname="$derived_name.yazi"
  local full_plugin_path="$YAZI_PLUGINS_DIR/$plugin_target_dirname"

  if [ -d "$full_plugin_path" ]; then
    echo "✅ Plugin '$derived_name' already installed."
    return
  fi

  if ! command -v ya &>/dev/null; then
    echo "❌ 'ya' not found."
    exit 1
  fi

  echo "🧩 Installing '$derived_name' using ya pkg add..."
  ya pkg add "$plugin_source"

  if [ -d "$full_plugin_path" ] || [ -d "$YAZI_PLUGINS_DIR/$derived_name" ]; then
    echo "👍 Installed '$derived_name'."
  else
    echo "⚠️ Install finished but plugin folder not detected for '$derived_name'."
  fi
}

install_yazi_plugin_git() {
  local repo_url="$1"
  local target_dir_name="$2"
  local full_plugin_path="$YAZI_PLUGINS_DIR/$target_dir_name"

  if [ -d "$full_plugin_path" ]; then
    echo "✅ Plugin '$target_dir_name' already installed (git)."
    return
  fi

  if ! command -v git &>/dev/null; then
    echo "❌ git not found."
    exit 1
  fi

  echo "🧩 Cloning '$target_dir_name'..."
  git clone "$repo_url" "$full_plugin_path"

  if [ -d "$full_plugin_path" ]; then
    echo "👍 Cloned '$target_dir_name'."
  else
    echo "⚠️ Clone failed for '$target_dir_name'."
  fi
}

# --- Main ---
echo "🚀 Starting Yazi plugin setup..."
setup_yazi_dirs
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

# what-size plugin
install_yazi_plugin "pirafrank/what-size"

# kdeconnect-send plugin
install_yazi_plugin "Deepak22903/kdeconnect-send"

echo "🎉 Yazi plugin setup finished."

