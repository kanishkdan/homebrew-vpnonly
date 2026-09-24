# homebrew-vpnonly

Homebrew tap for [VPNonly](https://github.com/kanishkdan/vpnonly): route only
the apps you choose through a WireGuard VPN on macOS, while everything else
keeps its normal connection.

```sh
brew tap kanishkdan/vpnonly
brew trust kanishkdan/vpnonly
brew install vpnonly
vpnonly
```

The formula installs the command-line version, which is MIT licensed. It
works with NordVPN only for now; see the
[main README](https://github.com/kanishkdan/vpnonly#install) for why. The menu
bar app at [vpnonly.app](https://vpnonly.app) works with any WireGuard provider.
