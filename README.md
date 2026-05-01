# zunel-hive/homebrew-tap

Personal Homebrew tap for [`zunel`](https://github.com/zunel-hive/zunel-binaries) — a Rust personal AI assistant.

## Install

```bash
brew tap zunel-hive/tap
brew install zunel
```

The formula `Formula/zunel.rb` is auto-bumped by the
[release pipeline](https://github.com/zunel-hive/zunel-binaries/releases)
on every stable tag. Each formula version references the per-arch
tarballs published as a GitHub Release on
`zunel-hive/zunel-binaries`.

## Upgrading

```bash
brew update
brew upgrade zunel
```

## What's `zunel`?

Local CLI personal-AI-assistant runtime: `zunel agent`, Slack
gateway, MCP servers, and more. See the
[zunel-binaries README](https://github.com/zunel-hive/zunel-binaries#readme)
for the full overview.
