# shell-proxy
Shell Proxy: SSH and Mosh terminal app. Release downloads (source is private).

## Install with Homebrew

This repository is also a Homebrew tap:

```sh
brew tap tpmullan/shell-proxy https://github.com/tpmullan/shell-proxy
brew install shell-proxy-agent        # the agent and the `jump` ProxyCommand
brew install --cask shell-proxy       # the macOS app (Apple silicon, macOS 14+)
brew upgrade                          # picks up new releases
```

The app is signed with a developer certificate but not notarized; the cask removes
the download quarantine flag so it opens without a Gatekeeper prompt.

Each release rewrites `Formula/` and `Casks/` from that release's `SHA256SUMS`
(`scripts/update_tap.py`; tests: `python3 -I scripts/test_update_tap.py`).
