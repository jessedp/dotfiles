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


### Claude Code settings
`~/.claude/settings.json` is a regular per-host file, not a symlink, so `/model`, `/config` and host-only
hooks never dirty this repo. Shared keys live in `claude/settings.base.json`; `./update` and `./install` run
`install-scripts/merge_claude_settings.sh`, which merges them in (base keys win, host-only keys and hooks stay).
To change a setting everywhere, edit `settings.base.json`, push, then `./update` on each host. Removing a key
from the base does not remove it from hosts.
