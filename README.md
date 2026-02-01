# dotfiles
dotfiles

### Installation

This repository uses a profile-based installation.

*   **`server` (default):** For headless systems. Installs all CLI tools.
*   **`desktop`:** For a full desktop environment. Installs all CLI tools plus GUI applications and desktop-specific configurations.

To install, clone the repository and run the `install` script. By default, it will perform a `server` installation. To install the `desktop` environment, pass `desktop` as an argument.

**Server Install (Default)**
```bash
git clone https://github.com/jessedp/dotfiles ~/.dotfiles && cd ~/.dotfiles && ./install && source ~/.bashrc
```

**Desktop Install**
```bash
git clone https://github.com/jessedp/dotfiles ~/.dotfiles && cd ~/.dotfiles && ./install desktop && source ~/.bashrc
```

### Update
To update your dotfiles, pull the latest changes and run the `./install` script again.

```bash
cd ~/.dotfiles && git pull --ff-only &&  ./install && source ~/.bashrc && git_prompt_reset 
```
*(On a desktop, use `./install desktop` in the command above.)*

