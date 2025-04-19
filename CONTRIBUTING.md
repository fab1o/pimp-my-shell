### CONTRIBUTING

# Contributing to `@fab1o/pimp-my-shell`

Thanks for your interest in contributing! 🎉  
This project is open to improvements, ideas, and bug fixes from the community.

---

## 🧰 Prerequisites

Before contributing, make sure you have the following tools installed:

- [Oh My Zsh](https://ohmyz.sh/)
- [Oh My Posh](https://ohmyposh.dev/)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [gum](https://github.com/charmbracelet/gum) (optional, but recommended)
- [GitHub CLI](https://github.com/cli/cli) (for testing GH-based features)

---

## 🚀 Getting Started

1. **Fork** the repository
2. **Clone** your fork locally:
   ```sh
   git clone https://github.com/<your-username>/pimp-my-shell.git
   cd pimp-my-shell
   ```

3. **Create a new branch** for your changes:
   ```sh
   git checkout -b my-cool-feature
   ```

4. Make your changes 🎯

---

## 🧪 Testing Your Changes

Make sure your aliases/functions work as expected.  
You can source your changes manually with:

```sh
source lib/pimp.zsh
source lib/config/pimp.cfg
```

Or add them to your `~/.zshrc` temporarily for real-world testing.

---

## ✅ Best Practices

- Keep functions/aliases portable and Zsh-compatible.
- Try to avoid hardcoded values unless absolutely necessary.
- Comment any tricky logic to help future contributors.
- Keep prompt themes clean, fast, and minimal.

---

## 📦 Submitting Your Contribution

1. Stage and commit your changes:
   ```sh
   git add .
   git commit -m "feat: add awesome new feature"
   ```

2. Push your branch:
   ```sh
   git push origin my-cool-feature
   ```

3. Open a Pull Request and describe your changes clearly.

---

## 💬 Questions or Suggestions?

Open an issue or start a discussion — feedback is always welcome!

---
