#!/bin/bash

# --- CONFIGURATION ---

# 1. Set the directory where your source config files are located.
#    This assumes you have cloned your git repo to ~/dotfiles/
DOTFILES_DIR="${HOME}/dotfiles"

# 2. Define the map: [ "source_filename_in_dotfiles" ]="target_link_in_home_directory"
#    The script will link: ~/dotfiles/KEY -> ~/.VALUE
declare -A mappings=(
    # Vim Configurations
    ["vimrc"]=".vimrc"

    # Tmux Configuration
    ["tmux.conf"]=".tmux.conf"
    
    # Shell Configuration
    ["zshrc"]=".zshrc"
)

# --- EXECUTION ---
echo "--- Starting Dotfile Sync Script ---"
echo "Source Directory: ${DOTFILES_DIR}"
echo ""

# Check if the dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "ERROR: Dotfiles source directory not found: $DOTFILES_DIR"
    echo "Please ensure your configs are in this directory."
    exit 1
fi

# Iterate over the keys (source files) in the map
for source_file in "${!mappings[@]}"; do
    target_link="${mappings[${source_file}]}"
    SOURCE_PATH="${DOTFILES_DIR}/${source_file}"
    TARGET_PATH="${HOME}/${target_link}"

    # 1. Check if the source file actually exists in the dotfiles repo
    if [ ! -e "$SOURCE_PATH" ]; then
        echo " [SKIP] Source file not found: $SOURCE_PATH"
        continue
    fi
    
    # 2. Check if the target file/link already exists in the home directory
    if [ -e "$TARGET_PATH" ]; then
        
        # Check if the existing target is already a symbolic link
        if [ -L "$TARGET_PATH" ]; then
            echo " [INFO] $TARGET_PATH is already a symlink. Keeping."
        else
            # It's an existing file or directory, not a symlink. We must remove it first.
            echo " [WARN] Found existing file $TARGET_PATH."
            echo "        -> REMOVING and creating symbolic link."
            
            # Using -rf for safety against directories, but consider making a backup first!
            rm -rf "$TARGET_PATH" 
            ln -s "$SOURCE_PATH" "$TARGET_PATH"
            echo " [DONE] Linked $source_file -> $target_link"
        fi
        
    else
        # Target does not exist. Simply create the link.
        ln -s "$SOURCE_PATH" "$TARGET_PATH"
        echo " [DONE] Created new link $source_file -> $target_link"
    fi
    
done

echo ""
echo "--- Sync Complete! ---"