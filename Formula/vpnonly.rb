class Vpnonly < Formula
  desc "Route only the apps you choose through a WireGuard VPN, not the whole Mac"
  homepage "https://github.com/kanishkdan/vpnonly"
  url "https://github.com/kanishkdan/vpnonly/releases/download/cli-1.0.12/vpnonly-cli-1.0.12.tar.gz"
  sha256 "5dc72b9687c695e2deaa0a2148339e7d2454072d5735004b24e08411731d82dc"
  license "MIT"

  depends_on "go" => :build
  depends_on "wireguard-tools"
  depends_on :macos

  def install
    # vpnrun calls setgid/setuid, so it must already be root. It is always
    # invoked through sudo, and deliberately carries no setgid bit.
    system ENV.cc, "-O2", "-o", "vpnrun", "vpnrun.c"

    # wireguard-go with VPNonly's inner-source rewrite, the same patch the Mac
    # app ships. Stock wireguard-go only works with NordVPN, whose servers
    # accept any inner source; everyone else's drop it. The script fetches the
    # pinned upstream source, checks its content hash, runs the patch's tests
    # and only then builds.
    system "./build-wireguard-go.sh", buildpath/"wireguard-go"

    libexec.install "vpnonly", "up.sh", "down.sh", "run.sh", "status.sh",
                    "fetch-creds.sh", "parse-wg.py", "vpnrun", "wireguard-go"
    chmod 0755, Dir[libexec/"*.sh"] + [libexec/"vpnonly", libexec/"vpnrun",
                                       libexec/"parse-wg.py", libexec/"wireguard-go"]

    # The scripts find their siblings by resolving this symlink, so linking
    # only the front end is enough.
    bin.install_symlink libexec/"vpnonly"
  end

  def caveats
    <<~EOS
      Creating a tunnel and firewall rules needs administrator rights, so
      vpnonly asks for your password. Just run:

        vpnonly

      First, connect a VPN. Either one works:

        NordVPN:        #{libexec}/fetch-creds.sh
        any WireGuard:  vpnonly import ~/Downloads/your-provider.conf

      The second covers Mullvad, Proton, IVPN, AirVPN, your own server, or
      any provider that gives you a WireGuard config file.

      Safari can't be routed by vpnonly, so it is left out of the list. The
      same goes for other WebKit browsers like Orion or DuckDuckGo: they still
      show up, but their pages would skip the tunnel, so don't pick them.
    EOS
  end

  test do
    # With no tunnel recorded, status reports down rather than adopting an
    # interface it does not own. That is the behaviour worth pinning.
    output = shell_output("#{libexec}/status.sh 2>&1", 0)
    assert_match "tunnel:   down", output

    # The bundled wireguard-go is the pinned version, not whatever is on PATH.
    assert_match "wireguard-go v0.0.20250522", shell_output("#{libexec}/wireguard-go --version")
  end
end
