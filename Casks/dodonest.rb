cask "dodonest" do
  version "1.0.0"
  sha256 "2aaf98ed1b8573e82d5df86fc6e9b594a6f6b744cd671f24528eb37f2f35aa49"

  url "https://github.com/bluewave-labs/dodonest/releases/download/v#{version}/DodoNest-#{version}.dmg"
  name "DodoNest"
  desc "Menu bar organizer for macOS"
  homepage "https://github.com/bluewave-labs/dodonest"

  # Requires macOS 14.0 Sonoma or later
  depends_on macos: ">= :sonoma"

  app "DodoNest.app"

  zap trash: [
    "~/Library/Preferences/com.dodonest.app.plist",
  ]

  caveats <<~EOS
    DodoNest requires Accessibility permissions to work.
    Go to System Settings > Privacy & Security > Accessibility
    and enable DodoNest.

    DodoNest is not notarized. On first launch, you may need to:
    1. Right-click the app and select "Open"
    2. Click "Open" in the security dialog

    Or run: xattr -cr /Applications/DodoNest.app
  EOS
end
