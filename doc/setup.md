# @fab1o/pimp-my-shell

## 🚀 Setup Instructions

### 1. Install Oh My Zsh & Oh My Posh

- Follow the official installation instructions for [Oh My Zsh](https://ohmyz.sh/) and [Oh My Posh](https://ohmyposh.dev/docs/installation/macos).
- This setup was developed on **macOS** and has not been tested on **Windows** or **Linux**.
- It's **strongly recommended** to install and use a [Nerd Font](https://ohmyposh.dev/docs/installation/fonts) for proper symbol rendering. A good example: [MesloLGM Nerd Font Propo](https://iterm2.com/documentation-fonts.html).
- Make sure your terminal is configured to use your chosen Nerd Font.

### 2. Install `gum` (optional, but recommended)

`gum` enhances user interaction with prompts and menus. While optional, some features **require** it.

- Install from: [https://github.com/charmbracelet/gum#installation](https://github.com/charmbracelet/gum#installation)

### 3. Install GitHub CLI (optional)

Some GitHub-related features (like PR creation) require the GitHub CLI (`gh`).

- Install from: [https://github.com/cli/cli](https://github.com/cli/cli)

### 4. Download the Source

Download the latest release from the [GitHub Releases page](https://github.com/fab1o/pimp-my-shell/releases).

### 5. Copy Contents to `$HOME`

Unzip and copy the files in [`dist`](../dist) manually or use the script below:

```sh
unzip ~/Downloads/pimp-my-shell-X.X.X.zip "pimp-my-shell-X.X.X/dist/*" -d temp_dir
mkdir -p $HOME/.pimp
cp -R temp_dir/pimp-my-shell-X.X.X/dist/. $HOME/.pimp
rm -rf temp_dir
```

Replace `X.X.X` with the correct version number.

> ⚠️ Not recommended for upgrades — this may overwrite your existing config files.

### 6. Configure Oh My Posh in `.zshrc`

Add the following to your `~/.zshrc`:

```sh
source "$HOME/.pimp/pimp.zsh"

# Prevent issues in Apple Terminal
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(pimp-my-shell init zsh --config $HOME/.pimp/pimp.omp.json)"
fi
```

### 7. Customize Your Settings

Edit `~/.pimp/config/pimp.zshenv` to customize your aliases and behaviors.

### 8. (Optional) Install iTerm2

While not required, iTerm2 provides a better terminal experience:

- Download: [https://iterm2.com](https://iterm2.com)

Recommended settings:
- Disable prompt arrows: *Profiles > Terminal > Uncheck "Show mark indicators"*
- Use the [Gruvbox color palette](https://github.com/herrbischoff/iterm2-gruvbox): *Profiles > Colors > Color Presets...*

### 9. You're Ready 🎉

- Open a new terminal session
- Type `help` to get started!

---
