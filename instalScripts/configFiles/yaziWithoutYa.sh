#!/bin/bash

PLUGINS_DIR="$HOME/.config/yazi/plugins"
mkdir -p "$PLUGINS_DIR"

# Clone yazi-rs/plugins monorepo (if not already)
YAZI_PLUGINS_REPO="$HOME/.local/share/yazi-rs-plugins"
if [ ! -d "$YAZI_PLUGINS_REPO" ]; then
  echo "Cloning yazi-rs/plugins monorepo..."
  git clone https://github.com/yazi-rs/plugins.git "$YAZI_PLUGINS_REPO"
else
  echo "yazi-rs/plugins already cloned. Pulling latest..."
  git -C "$YAZI_PLUGINS_REPO" pull
fi

copy_plugin_from_monorepo() {
  local name="$1"
  local src="$YAZI_PLUGINS_REPO/$name"
  local dest="$PLUGINS_DIR/$name"
  if [ -d "$src" ]; then
    if [ ! -d "$dest" ]; then
      echo "Installing plugin: $name"
      cp -r "$src" "$dest"
    else
      echo "Plugin already exists: $name"
    fi
  else
    echo "Plugin $name not found in monorepo!"
  fi
}

clone_if_missing() {
  local repo="$1"
  local name="$2"
  local target_dir="$PLUGINS_DIR/$name"
  if [ ! -d "$target_dir" ]; then
    echo "Cloning $repo into $target_dir"
    git clone "$repo" "$target_dir" || echo "Failed to clone $name"
  else
    echo "Skipping $name (already exists)"
  fi
}

# Clone valid external plugin repos
clone_if_missing https://github.com/imsi32/yatline-catppuccin.yazi.git yatline-catppuccin.yazi

# Valid plugin folders from yazi-rs monorepo
copy_plugin_from_monorepo full-border.yazi
copy_plugin_from_monorepo open_with_cmd
copy_plugin_from_monorepo jump_to_char
copy_plugin_from_monorepo chmod
copy_plugin_from_monorepo toggle_pane
copy_plugin_from_monorepo git
copy_plugin_from_monorepo mount
copy_plugin_from_monorepo copy_file_contents
copy_plugin_from_monorepo compress
