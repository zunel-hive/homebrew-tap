class Zunel < Formula
  desc "Rust CLI and gateway for the Zunel personal AI assistant."
  homepage "https://github.com/zunel-hive/zunel-binaries"
  version "0.2.6"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.6/zunel-cli-aarch64-apple-darwin.tar.xz"
      sha256 "5e7835857edd108bb758aedaf2dcea7701af801bc50560d20d2adef5f69ab740"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.6/zunel-cli-x86_64-apple-darwin.tar.xz"
      sha256 "0557249a193e4236cf3331d6067c247993d69af76193b6b4c78963855bb2382b"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.6/zunel-cli-aarch64-unknown-linux-musl.tar.xz"
      sha256 "f63fd3eb9c499fd91bf696b3963169c6715c77e390ea42f185dc08ce247574bc"
    end
    if Hardware::CPU.intel?
      url "https://github.com/zunel-hive/zunel-binaries/releases/download/v0.2.6/zunel-cli-x86_64-unknown-linux-musl.tar.xz"
      sha256 "c70656c9b2452182d9d65ebb384856c991230d44a24295580908e99bc42884a4"
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
