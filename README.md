# mcmacos

A collection of tools, scripts and configuration files for setting up a MacOS device so that it doesn't suck.

## Essential Applications

- [Google Chrome](https://www.google.com/intl/en_uk/chrome/)
- [Raycast](https://www.raycast.com/)
- [Visual Studio Code](https://code.visualstudio.com/)

## Quick start

1. Manually install the applications above.

2. Run the bootstrap script:

```bash
./bootstrap.sh
```

## File Reference

### bootstrap.sh

A script to set up a new MacOS device, configuring device setting and ensuring essential tools and packages are installed and configured.

### .gitconfig
A Git configuration file with user details and preferred settings.

### Brewfile

A simple list of Homebrew formulae and casks for essential tools and apps — apply with `brew bundle` (run automatically by the bootstrap script).
