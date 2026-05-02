# zunel-hive/homebrew-tap

Personal Homebrew tap **and** binary host for `zunel` — a Rust
personal AI assistant with a local CLI, Slack gateway, and MCP
tooling.

This repo serves two purposes:

- **Homebrew tap.** `Formula/zunel.rb` is auto-bumped by the release
  pipeline on every stable tag, so `brew tap zunel-hive/tap && brew
  install zunel` Just Works.
- **Public binary host.** Per-arch tarballs and `.deb` packages for
  every release are uploaded as GitHub Release assets on this repo.
  The Homebrew formula and the `dpkg` install instructions below both
  pull from those releases.

No source code lives here; the Rust source is maintained privately.

---

## Install

### macOS / Linux — Homebrew (recommended)

```bash
brew tap zunel-hive/tap
brew install zunel
```

### Debian / Ubuntu — `.deb`

```bash
ARCH=$(dpkg --print-architecture)               # amd64 or arm64
TAG=$(curl -sL https://api.github.com/repos/zunel-hive/homebrew-tap/releases/latest \
        | grep -o '"tag_name":[^,]*' | head -n1 | cut -d'"' -f4)
curl -fsSL -o /tmp/zunel.deb \
  "https://github.com/zunel-hive/homebrew-tap/releases/download/${TAG}/zunel-${ARCH}.deb"
sudo dpkg -i /tmp/zunel.deb
```

The package depends on nothing beyond `ca-certificates` (already
present on most systems); the binary is statically linked against
musl + rustls, so there's no `libssl` / `libc` version coupling.

### Direct download

Browse [Releases](https://github.com/zunel-hive/homebrew-tap/releases)
for raw tarballs:

| Triple                       | Audience                  |
| ---------------------------- | ------------------------- |
| `aarch64-apple-darwin`       | macOS Apple Silicon       |
| `x86_64-apple-darwin`        | macOS Intel               |
| `aarch64-unknown-linux-musl` | Linux arm64 (static musl) |
| `x86_64-unknown-linux-musl`  | Linux amd64 (static musl) |

---

## User guide

### 1. First-run setup

```bash
zunel onboard
```

This creates:

- `~/.zunel/config.json` — the runtime config
- `~/.zunel/workspace/`  — the default agent workspace

Re-run `zunel onboard --force` to regenerate the default config.

### 2. Configure a provider

`zunel` ships two provider paths. Pick one by editing
`~/.zunel/config.json`.

**Option A — OpenAI-compatible endpoint (`providers.custom`):**

```json
{
  "providers": {
    "custom": {
      "apiKey": "sk-...",
      "apiBase": "https://api.openai.com/v1"
    }
  },
  "agents": {
    "defaults": {
      "provider": "custom",
      "model": "gpt-4o-mini"
    }
  }
}
```

`apiBase` can point at any OpenAI-compatible service you trust.
`apiKey` is required by the runtime even if your endpoint only
expects a placeholder.

**Option B — ChatGPT Codex via local OAuth (`providers.codex`):**

First sign in with the `codex` CLI (once, with your ChatGPT
account). Then:

```json
{
  "providers": {
    "codex": {}
  },
  "agents": {
    "defaults": {
      "provider": "codex",
      "model": "gpt-5.4"
    }
  }
}
```

No API key needed — `zunel` reads the local Codex OAuth token. If
you're not signed in yet, `zunel` returns a clear error pointing at
`codex` CLI login.

### 3. Chat with the agent locally

```bash
zunel agent                       # interactive chat
zunel agent -m "Summarize this repo."   # one-shot prompt
zunel agent --show-tokens         # print a per-turn token-usage footer
```

### 4. (Optional) Run the Slack gateway

Add a Slack block to `~/.zunel/config.json`:

```json
{
  "channels": {
    "slack": {
      "enabled": true,
      "mode": "socket",
      "botToken": "xoxb-...",
      "appToken": "xapp-...",
      "allowFrom": ["*"]
    }
  }
}
```

Then start the gateway:

```bash
zunel gateway
```

The gateway runs Slack Socket Mode, cron jobs, the Dream memory
loop, the heartbeat, the built-in MCP servers, and remote
approvals — all using the same workspace and agent defaults as the
local CLI.

If you installed via Homebrew on macOS, the formula registers a
`brew services` job so you can also run it as a background service:

```bash
brew services start zunel-hive/tap/zunel
brew services restart zunel-hive/tap/zunel
brew services stop zunel-hive/tap/zunel
```

Logs land at:

- `$(brew --prefix)/var/log/zunel-gateway.out.log`
- `$(brew --prefix)/var/log/zunel-gateway.err.log`

### 5. Sanity-check the setup

```bash
zunel status            # provider, model, workspace, channel count
zunel channels status   # Slack channel status
```

A working setup prints something like:

```text
provider: custom
model: gpt-4o-mini
workspace: /Users/you/.zunel/workspace
channels: 1
```

`channels` is `1` when the Slack channel is configured, `0` when
it's not.

---

## Command cheat sheet

```text
zunel onboard                        # initialize or refresh config + workspace
zunel agent                          # interactive CLI chat
zunel agent -m "..."                 # one-shot prompt
zunel agent --show-tokens            # per-turn token-usage footer
zunel gateway                        # start the Slack-backed gateway
zunel status                         # provider/model/workspace/channel summary
zunel channels status                # Slack channel status

zunel sessions list                  # heaviest persisted sessions on disk
zunel sessions show <key>            # tail of a specific session
zunel sessions compact <key>         # LLM-summarize a bloated session
zunel sessions prune --older-than 30d  # delete stale sessions

zunel tokens                         # lifetime grand total across all sessions
zunel tokens list                    # per-session token table sorted by total
zunel tokens show <key>              # per-turn breakdown for one session
zunel tokens since 7d                # rolling window roll-up

zunel slack login                    # mint a Slack user token for the Slack MCP
zunel mcp serve --server self        # built-in `self` MCP server (stdio)
zunel mcp serve --server slack       # built-in Slack MCP server (stdio)
zunel mcp login <server>             # OAuth-login a configured remote MCP server

zunel profile list                   # list side-by-side profiles
zunel profile use <name>             # set a profile as the sticky default
zunel profile show                   # show the active profile and home dir
zunel profile rm <name>              # delete a profile (asks to confirm)
```

### Global flags

| Flag                              | Description                                                                                              |
| --------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `--config <path>`                 | Override the config file path. Also readable from `ZUNEL_CONFIG`; the flag wins when both are set.       |
| `-p <name>` / `--profile <name>`  | Run any subcommand under `~/.zunel/profiles/<name>/` (ignored when `ZUNEL_HOME` is set).                 |

Run `zunel --help` for the full command surface and
`zunel <subcommand> --help` for per-subcommand options.

---

## Upgrading

```bash
# Homebrew
brew update
brew upgrade zunel

# .deb — re-run the install snippet above; `dpkg -i` overwrites in place.
```

## Uninstall

```bash
# Homebrew
brew services stop zunel-hive/tap/zunel 2>/dev/null || true
brew uninstall zunel
brew untap zunel-hive/tap   # optional

# .deb
sudo dpkg -r zunel
```

`zunel` never touches anything outside `~/.zunel/`. To wipe runtime
state too:

```bash
rm -rf ~/.zunel
```

---

## License

MIT — see the `LICENSE` file bundled inside each release tarball.
