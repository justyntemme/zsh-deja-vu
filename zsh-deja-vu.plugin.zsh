# zsh-deja-vu.plugin.zsh
#
# "That feeling you've run this command *here* before?"
#
# Logs Zsh command history per directory and provides `djvu` (static)
# and `djvi` (interactive) to query it.

# --- Configuration ---

# Set the location of the directory-specific history file.
# Uses $ZDOTDIR if set (common for zsh configs), otherwise $HOME.
: "${ZSH_DEJA_VU_HISTORY_FILE:=${ZDOTDIR:-$HOME}/.zsh_deja_vu_history}"

# --- History Logging ---

autoload -U add-zsh-hook

# Runs *before* a command is executed
_zsh_deja_vu_preexec() {
    local cmd="$1"

    # Don't log empty commands
    if [[ -z "$cmd" ]]; then
        return
    fi

    # Don't log our own plugin's commands (prevents feedback loop)
    case "$cmd" in
        (djvu*|djvi*) return 0 ;;
    esac

    # Log in format: /full/path/to/dir:<command>
    print -r -- "$(pwd):$cmd" >> "$ZSH_DEJA_VU_HISTORY_FILE"
}

# Register the hook
add-zsh-hook preexec _zsh_deja_vu_preexec

# --- Query Functions ---

##
# djvu: (Déjà vu) Shows command history for the current or a specified directory.
#
# Usage:
#   djvu        # Shows history for the *current* directory
#   djvu <path> # Shows history for the *specified* path
##
djvu() {
    if [[ ! -f "$ZSH_DEJA_VU_HISTORY_FILE" ]]; then
        print "zsh-deja-vu: No history logged yet."
        print "Run a few commands to populate $ZSH_DEJA_VU_HISTORY_FILE"
        return 1
    fi

    local target_dir
    local dir_label

    if [[ -n "$1" ]]; then
        # User provided a path.
        if [[ ! -d "$1" ]]; then
             print "djvu: error: directory not found: $1"
             return 1
        fi
        # ":A" is Zsh magic to resolve to an absolute, real path
        target_dir="${1:A}"
        dir_label="$1"
    else
        # No path provided, use current directory.
        target_dir="$(pwd)"
        dir_label="."
    fi

    local prefix="${target_dir}:"

    # Use awk to find and print matching lines, stripping the prefix
    local output
    output=$(awk -v pfx="$prefix" '
        $0 ~ "^" pfx {
            print substr($0, length(pfx) + 1)
        }
    ' "$ZSH_DEJA_VU_HISTORY_FILE")

    if [[ -z "$output" ]]; then
        print "djvu: No history found for: $target_dir"
    else
        print "--- Déjà Vu for $dir_label ($target_dir) ---"
        # Pipe the output to `nl` (number lines) to look like 'history'
        print -r -- "$output" | nl -b a -w 6
    fi
}

##
# djvi: (Déjà Vu Interactive)
#
# Searches the *entire* context history with fzf and places
# the selected command into the command line buffer.
##
djvi() {
    if ! command -v fzf &>/dev/null; then
        print "zsh-deja-vu: Error: fzf (fuzzy finder) is not installed."
        print "Please install fzf to use the 'djvi' command."
        return 1
    fi

    if [[ ! -f "$ZSH_DEJA_VU_HISTORY_FILE" ]]; then
        print "zsh-deja-vu: No history logged yet."
        return 1
    fi

    # Use fzf to select a command.
    # --tac: Show most recent (bottom of file) first.
    # --preview: Show just the command (strip the path prefix) in the preview window.
    # --query="$LBUFFER": Pre-fill fzf with whatever you've already typed.
    local selected_line
    selected_line=$(
        tac "$ZSH_DEJA_VU_HISTORY_FILE" | fzf \
            --height 40% \
            --border \
            --preview="echo {} | sed 's/^[^:]*://'" \
            --preview-window="top,70%" \
            --prompt="DejaVu> " \
            --query="$LBUFFER"
    )

    # If a line was selected (fzf didn't exit empty)
    if [[ -n "$selected_line" ]]; then
        # Strip the path prefix, leaving just the command
        local command_to_run
        command_to_run=$(echo "$selected_line" | sed 's/^[^:]*://')
        
        # Clear the current line buffer
        zle -R "select-word"
        
        # Put the selected command into the buffer
        print -z "$command_to_run"
    fi
}

# --- ZLE & Keybinding Setup ---

# Register `djvi` as a Zsh Line Editor (zle) widget
zle -N djvi-widget djvi

# Check if the widget is already bound to a key.
# If not, set our default `Ctrl+F`.
# Users can override this in their .zshrc if they want a different key.
if ! bindkey -L | grep -q "djvi-widget"; then
    bindkey '^F' djvi-widget
fi