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
works with NordVPN (paste an access token once) and with any provider that
gives you a WireGuard config file:

```sh
vpnonly import ~/Downloads/your-provider.conf
```

That covers Mullvad, Proton, IVPN, AirVPN and your own server. The formula
builds wireguard-go from pinned source with VPNonly's inner-source patch,
which is what those providers need; see the
[main README](https://github.com/kanishkdan/vpnonly#how-it-works) for why. It
needs Go to build, which Homebrew installs for you.

The menu bar app at [vpnonly.app](https://vpnonly.app) does the same with
switches instead of a terminal.
