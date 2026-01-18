# mcmacos

A collection of tools, scripts and configuration files for setting up a macOS device so that it doesn't suck.

## Essential Applications

- [Google Chrome](https://www.google.com/intl/en_uk/chrome/)
- [Raycast](https://www.raycast.com/)
- [Visual Studio Code](https://code.visualstudio.com/)

## Quick Start

1. Manually install the applications above.

2. Run the bootstrap script:

```bash
curl -fsSL https://raw.githubusercontent.com/Kevin-McGonigle/mcmacos/main/bootstrap.sh | bash
```

## What does it do?
- Installs [Xcode Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/).
- Installs [Homebrew](https://brew.sh/) to manage packages.
- Installs and configures essential development tools:
  - [Git](https://git-scm.com/)
  - [Claude Code](https://code.claude.com/)
  - [Gemini CLI](https://geminicli.com/)
  - [GitHub CLI](https://cli.github.com/)
  - [Warp](https://warp.dev/)
  - [NVM](https://github.com/nvm-sh/nvm) with the latest LTS Node.js, plus global packages:
    - `@google/gemini-cli`
    - `pnpm`
  - [UV](https://docs.astral.sh/uv/) with the latest Python, plus `ruff`.
- Configures macOS system settings:
  - Appearance (Dark Mode)
  - Dock (size, auto-hide, etc.) and Hot Corners
  - Menu Bar (icons, clock with seconds, battery percentage)
  - Keyboard shortcuts (disables Spotlight, Globe/Fn key)
  - Trackpad & Mouse (tracking speed, tap-to-click, etc.)