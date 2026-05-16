class Zunel < Formula
  desc "CLI and Slack gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-bot/homebrew-tap"
  version "1.1.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.1/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "00f4c0764ae5e9a5c97f7e0eab60c3f5f6e05a003c7dd05f6c1cc9dedfa79fd1"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.1/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "1b4ae754a50adf688963aa7a80af0c1737baa6dee1a7c8835816ff3df702d8d5"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.1/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "2201b9a9ff89d71de54b19e2d6b952d821c9ac1aef29989e07ef8266f76f80b5"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-bot/homebrew-tap/releases/download/v1.1.1/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "22db886803a424ff7b3b73b28985c0ecd0aace3373eba0ea132ae7de9b487a67"
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
