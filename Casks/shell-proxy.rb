cask "shell-proxy" do
  version "0.14.0"
  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.0/Shell-Proxy-0.14.0-macos-arm64.tar.gz"
  sha256 "832e54bdd82d45bef90aa822c1d912fc130350df1b8503a01530ef533b07c5bf"

  name "Shell Proxy"
  desc "SSH and Mosh terminal app"
  homepage "https://github.com/tpmullan/shell-proxy"

  app "Shell Proxy.app"

  # The app is signed with a developer certificate but not notarized, so strip
  # the download quarantine rather than make every upgrade hit Gatekeeper.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Shell Proxy.app"],
                   must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.tpmullan.shellproxy",
    "~/Library/Caches/com.tpmullan.shellproxy",
    "~/Library/Preferences/com.tpmullan.shellproxy.plist",
  ]
end
