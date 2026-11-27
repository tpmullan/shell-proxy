cask "shell-proxy" do
  version "0.14.1"
  sha256 "f9fde5238577db04fa36abc541af264e3f9d326c748f7ee8e5f68c1de9c19fe3"

  url "https://github.com/tpmullan/shell-proxy/releases/download/v0.14.1/Shell-Proxy-0.14.1-macos-arm64.tar.gz"
  name "Shell Proxy"
  desc "SSH and Mosh terminal app"
  homepage "https://github.com/tpmullan/shell-proxy"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Shell Proxy.app"

  # The app is signed with a developer certificate but not notarized, so strip
  # the download quarantine rather than make every upgrade hit Gatekeeper.
  postflight_steps do
    run "/usr/bin/xattr",
        args:         ["-dr", "com.apple.quarantine", "{{appdir}}/Shell Proxy.app"],
        must_succeed: false
  end

  zap trash: [
    "~/Library/Application Support/com.tpmullan.shellproxy",
    "~/Library/Caches/com.tpmullan.shellproxy",
    "~/Library/Preferences/com.tpmullan.shellproxy.plist",
  ]
end
