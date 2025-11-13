# zsh-deja-vu

"That feeling you've run this command *here* before?"

A Zsh plugin that logs and retrieves command history based on the directory it was run in. Never forget that complex `docker` or `git` command you ran in a project folder weeks ago.

!

## Features

* **Logs commands with their directory:** Silently in the background.
* **`djvu`**: A command to show history for the **current directory**, just like `history`.
* **`djvu <path>`**: Lets you query the history for **any directory**.
* **`djvi`**: An interactive **fuzzy finder** (using `fzf`) to search your *entire* directory history and bring the command back to your prompt.

## Installation

### Prerequisites

* **fzf**: Required for the interactive search (`djvi`).
    [Install fzf here](https://github.com/junegunn/fzf).

### For Zsh Plugin Managers (Oh My Zsh, etc.)

1.  Clone this repository into your plugin manager's custom plugin directory.

    **Oh My Zsh:**
    ```zsh
    git clone [https://github.com/YOUR_USERNAME/zsh-deja-vu.git](https://github.com/YOUR_USERNAME/zsh-deja-vu.git) \
      ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-deja-vu
    ```

2.  Add `zsh-deja-vu` to the `plugins` list in your `~/.zshrc` file:

    ```zsh
    plugins=(
        # ... other plugins
        zsh-deja-vu
    )
    ```

### Manual (No Plugin Manager)

1.  Clone this repository somewhere:
    ```zsh
    git clone [https://github.com/YOUR_USERNAME/zsh-deja-vu.git](https://github.com/YOUR_USERNAME/zsh-deja-vu.git) \
      ~/.zsh/zsh-deja-vu
    ```

2.  Add this line to your `~/.zshrc`:
    ```zsh
    source ~/.zsh/zsh-deja-vu/zsh-deja-vu.plugin.zsh
    ```

3.  Restart your shell (`exec zsh`).

## Usage

### 1. Static History (`djvu`)

* **Current Directory:** Just type `djvu`.
    ```zsh
    ~/projects/my-app > djvu
    --- Déjà Vu for . (~/projects/my-app) ---
         1  ls -la
         2  docker-compose up -d
         3  git status
    ```
* **Another Directory:** Pass any path as an argument.
    ```zsh
    > djvu ~/docs
    --- Déjà Vu for ~/docs (~/docs) ---
         1  mkdocs serve
         2  ls
    ```

### 2. Interactive Search (`djvi` & Keybinding)

This is the killer feature. The plugin provides a `djvi-widget` for Zsh. To use it, you need to bind it to a key in your `~/.zshrc`.

**We recommend `Alt+R` (or `Option+R` on Mac).**

Add this line to your `~/.zshrc`:

```zsh
# Binds Alt+R to the Deja Vu Interactive search
bindkey '^[r' djvi-widget
```

(You *can* bind it to `Ctrl+R` with `bindkey '^R' djvi-widget`, but this will override Zsh's default reverse-search. `Alt+R` is a safe, common alternative.)

Now, whenever you press `Alt+R`, `fzf` will open. You can type `projects` to see commands from your projects folder, then type `docker` to narrow it down, all in one search.

### Customization

You can change the location of the history log file by setting this variable in your `~/.zshrc` *before* the plugin is sourced:

```zsh
export ZSH_DEJA_VU_HISTORY_FILE="~/.my-custom-location"
```

## License

MIT
