class Vpnonly < Formula
  desc "Route only the apps you choose through a WireGuard VPN, not the whole Mac"
  homepage "https://github.com/kanishkdan/vpnonly"
  url "https://github.com/kanishkdan/vpnonly/releases/download/cli-1.0.5/vpnonly-cli-1.0.5.tar.gz"
  sha256 "8d63ef256b5e4130faf9dff4dcc20d440eadfd1fa709219796b3fa62921e553e"
  license "MIT"

  depends_on "wireguard-go"
  depends_on "wireguard-tools"
  depends_on :macos

  def install
    # vpnrun calls setgid/setuid, so it must already be root. It is always
    # invoked through sudo, and deliberately carries no setgid bit.
    system ENV.cc, "-O2", "-o", "vpnrun", "vpnrun.c"

    libexec.install "vpnonly", "up.sh", "down.sh", "run.sh", "status.sh",
                    "fetch-creds.sh", "parse-wg.py", "vpnrun"
    chmod 0755, Dir[libexec/"*.sh"] + [libexec/"vpnonly", libexec/"vpnrun", libexec/"parse-wg.py"]

    # The scripts find their siblings by resolving this symlink, so linking
    # only the front end is enough.
    bin.install_symlink libexec/"vpnonly"
  end

  def caveats
    <<~EOS
      Creating a tunnel and firewall rules needs administrator rights, so
      vpnonly asks for your password. Just run:

        vpnonly

      First time, set up a provider:

        NordVPN            #{libexec}/fetch-creds.sh
        anything else      put your provider's .conf somewhere, then
                           sudo #{libexec}/up.sh /path/to/provider.conf

      Safari and other WebKit apps cannot be routed by any per-app VPN on
      macOS, so they are left out of the list.
    EOS
  end

  test do
    # With no tunnel recorded, status reports down rather than adopting an
    # interface it does not own. That is the behaviour worth pinning.
    output = shell_output("#{libexec}/status.sh 2>&1", 0)
    assert_match "tunnel:   down", output
  end
end
