# mcmacos

A collection of tools, scripts and configuration files for setting up a MacOS device so that it doesn't suck.

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
- Installs [Xcode Command Line Tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/)
- Installs [Homebrew](https://brew.sh/)
- Congigures [Git](https://git-scm.com/)
- Installs [Claude Code](https://code.claude.com/)
- Installs [Gemini CLI](https://geminicli.com/)
- Installs [GitHub CLI](https://cli.github.com/)
- Installs [Warp](https://warp.dev/)
- Installs [NVM](https://github.com/nvm-sh/nvm) and the latest LTS version of Node.js
- Installs [UV](https://docs.astral.sh/uv/) and the latest version of Python