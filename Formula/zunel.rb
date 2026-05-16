class Zunel < Formula
  desc "CLI and Slack gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-bot/homebrew-tap"
  version "1.0.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.0.0/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "f314b48eeead9bbc0128c457768a4b4aa0512eaa2f25cee3951548e29cd2f6df"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.0.0/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "3b4b812743b2bccb090b4b757809d9ac535ece25969dc9f6a67669c0de53eb19"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.0.0/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "88ceba3ef65c7e2d32ee5be692ec899a4386e8080ba279dec529f9b583d23f8a"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.0.0/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "a1ddc2e530c53caf4b98013ed8b998fe4daddf3f8b13f18d81f69230ee9a81ed"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":               {},
    "aarch64-unknown-linux-gnu":          {},
    "aarch64-unknown-linux-musl-dynamic": {},
    "aarch64-unknown-linux-musl-static":  {},
    "x86_64-apple-darwin":                {},
    "x86_64-unknown-linux-gnu":           {},
    "x86_64-unknown-linux-musl-dynamic":  {},
    "x86_64-unknown-linux-musl-static":   {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "zunel" if OS.mac? && Hardware::CPU.arm?
    bin.install "zunel" if OS.mac? && Hardware::CPU.intel?
    bin.install "zunel" if OS.linux? && Hardware::CPU.arm?
    bin.install "zunel" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end

  service do
    run [opt_bin/"zunel", "gateway"]
    keep_alive true
    log_path var/"log/zunel-gateway.out.log"
    error_log_path var/"log/zunel-gateway.err.log"
    environment_variables RUST_LOG: "info,zunel=info",
                          PATH:     "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
  end
end
