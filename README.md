# claude-litellm

**Isolated LiteLLM Profile Manager & Interactive Launcher for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).**

`claude-litellm` lets you connect Claude Code (`claude`) to one or more **LiteLLM Proxy** (or compatible Anthropic-gateway) servers without touching, overwriting, or conflicting with your primary `~/.claude` configuration, OAuth credentials, or default model settings.

---

## Why `claude-litellm`?

If you already use `claude` on your machine (via a Claude subscription, Vertex/Bedrock, or an enterprise gateway), running Claude Code against a custom LiteLLM server usually causes friction:

1. **Configuration Collisions:** Changing `/model` or `settings.json` for a LiteLLM server overwrites `~/.claude/settings.json`, breaking your primary `claude` setup.
2. **Authentication Conflicts:** Inherited `ANTHROPIC_*` environment variables or stored Keychain credentials clash when switching between your normal `claude` workflow and a LiteLLM proxy.
3. **Repetitive Exporting:** Manually exporting `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` across multiple LiteLLM environments (local, staging, enterprise) is tedious and error-prone.

`claude-litellm` solves all three by providing a **zero-dependency interactive TUI** that stores multiple LiteLLM server profiles securely and launches `claude` inside a **per-profile isolated `CLAUDE_CONFIG_DIR`**.

---

## Features

- **Full Environment & Config Isolation:**
  - Each profile runs in its own isolated `CLAUDE_CONFIG_DIR` (`~/.claude-litellm/envs/<profile-id>`).
  - Your main `~/.claude/settings.json`, OAuth logins, and normal `claude` command remain **100% untouched**.
  - Conflicting parent-shell variables (`ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`, `ANTHROPIC_MODEL`, `CLAUDE_CODE_USE_BEDROCK`, `CLAUDE_CODE_USE_VERTEX`, etc.) are automatically scrubbed before launch.
- **Zero-Friction Startup:**
  - Automatically pre-seeds onboarding state and workspace trust flags so Claude Code opens straight to the prompt without repeating first-run wizards.
  - Symlinks your existing `~/.claude/plugins`, `skills`, `commands`, and `agents` into the isolated environment so all your custom extensions still work.
- **Interactive Profile Manager (TUI):**
  - First run prompts for **Server URL**, **Profile Name**, **API Key**, and optional **Default Model**.
  - Subsequent runs display an interactive menu navigable via **Up/Down arrow keys (`↑`/`↓`)** or **number keys (`1-9`)**, with the last used profile pre-selected for instant `Enter`-to-launch.
  - Built-in flows to **Add (`a`)**, **Edit (`e`)**, **Delete (`d`)**, and **Pick/Test Models (`m`)**.
- **Live `/v1/models` Auto-Discovery:**
  - Queries your LiteLLM server's `/v1/models` endpoint when creating or editing a profile (or pressing `m` in the menu) so you can pick from a live numbered list of available models.
- **Secure Local Storage:**
  - Profiles and API keys are stored in `~/.claude-litellm/profiles.json` with strict `0600` (owner-only read/write) permissions and masked in the UI (`sk-1••••abcd`).
- **Zero External Dependencies:**
  - Single-file Python 3 script using only the Python standard library (`tty`, `termios`, `urllib`, `json`, `ssl`). Works out of the box on macOS and Linux.

---

## Interactive TUI Preview

```text
  ╭──────────────────────────────────────────────────────────────────────────╮
  │   ⚡ CLAUDE-LITELLM — Isolated Server & Profile Launcher                 │
  ╰──────────────────────────────────────────────────────────────────────────╯

  Saved LiteLLM Profiles: (Use ↑/↓ arrows or 1-9 number keys to select)

  ❯ [1] Enterprise LiteLLM ★ last used
      Server: https://litellm.internal.example.com   Key: sk-p••••9f2a   Model: claude-sonnet-4-5

    [2] Local LiteLLM Proxy
      Server: http://localhost:4000   Key: sk-1••••4400   Model: default

  ────────────────────────────────────────────────────────────────────────────
  [Enter] Launch   [a / +] Add New   [e] Edit   [m] Pick/Test Model   [d] Delete   [q] Quit
  ────────────────────────────────────────────────────────────────────────────
```

---

## Requirements

- **macOS** or **Linux**
- **Python 3.8+** (pre-installed on macOS and most Linux distributions)
- **[Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)** (`claude` available in `~/.local/bin/claude` or `$PATH`)

---

## Installation

### Option 1: Clone & Run Installer (Recommended)

```bash
git clone https://github.com/flyingbirdinc/claude-litellm.git
cd claude-litellm
./install.sh
```

This installs the executable to `~/.local/bin/claude-litellm`.

### Option 2: Direct Single-File Install

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/flyingbirdinc/claude-litellm/main/claude-litellm -o ~/.local/bin/claude-litellm
chmod +x ~/.local/bin/claude-litellm
```

Ensure `~/.local/bin` is in your `$PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

---

## Usage

### 1. First Run
Simply run:

```bash
claude-litellm
```

When no profiles exist yet, `claude-litellm` walks you through creating your first profile:
1. **LiteLLM Server URL** (e.g. `http://localhost:4000` or `https://litellm.company.com`)
2. **Profile Name** (defaults to the server hostname if left blank)
3. **LiteLLM API Key** (hidden terminal input)
4. **Default Model** (queries `<server_url>/v1/models` live and lets you pick a model by number, enter one manually, or skip)
5. **Auth Header Mode** (defaults to `ANTHROPIC_AUTH_TOKEN` / `Bearer`, recommended for LiteLLM Proxy)

### 2. Subsequent Runs (Interactive Menu)
Run `claude-litellm` to open the profile manager:

| Key | Action |
| :--- | :--- |
| `↑` / `↓` or `k` / `j` | Move selection up or down |
| `Enter` | Launch `claude` with the selected profile |
| `1` – `9` | Immediately select & launch profile `#1` – `#9` |
| `a` or `+` | Add a new LiteLLM server profile |
| `e` | Edit the selected profile (press `Enter` on any field to keep its current value) |
| `m` or `t` | Connect to `<server_url>/v1/models` and pick/update the profile's default model |
| `d` | Delete the selected profile (and its isolated config directory) |
| `q` or `Esc` | Quit |

### 3. CLI Shortcuts & Forwarding Arguments to `claude`

Any arguments not consumed by `claude-litellm` are forwarded directly to the underlying `claude` CLI:

```bash
# Open profile selector and resume a previous conversation (-r / --resume)
claude-litellm -r

# Open profile selector and continue the most recent session (-c / --continue)
claude-litellm -c

# Skip the menu and immediately launch with the last-used profile
claude-litellm --last
claude-litellm -l -c

# Launch a specific profile by name or number (with optional claude flags)
claude-litellm --profile "Local LiteLLM"
claude-litellm -P 1 "Explain the architecture of this repository"

# Manage profiles directly from the command line
claude-litellm --add
claude-litellm --edit
claude-litellm --list
claude-litellm --help
```

---

## How Isolation Works Under the Hood

```text
~/.claude-litellm/
├── profiles.json          # Saved server profiles & API keys (chmod 0600)
└── envs/
    ├── <profile-id-1>/    # Isolated CLAUDE_CONFIG_DIR for Profile 1
    │   ├── .claude.json   # Pre-seeded onboarding & workspace trust
    │   ├── settings.json  # Profile-specific model & theme settings
    │   ├── plugins -> ~/.claude/plugins
    │   ├── skills  -> ~/.claude/skills
    │   ├── commands -> ~/.claude/commands
    │   └── agents  -> ~/.claude/agents
    └── <profile-id-2>/    # Isolated CLAUDE_CONFIG_DIR for Profile 2
```

When you launch a profile, `claude-litellm`:
1. Creates/updates `~/.claude-litellm/envs/<profile-id>` and sets `CLAUDE_CONFIG_DIR` to that path.
2. Scrubs any inherited `ANTHROPIC_*` and third-party provider variables from the child process environment.
3. Injects:
   - `CLAUDE_CONFIG_DIR=~/.claude-litellm/envs/<profile-id>`
   - `ANTHROPIC_BASE_URL=<profile.server_url>`
   - `ANTHROPIC_AUTH_TOKEN=<profile.api_key>` (or `ANTHROPIC_API_KEY` depending on profile auth mode)
   - `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`
   - `ANTHROPIC_MODEL=<profile.model>` (if a default model is configured)
4. Replaces the current process with `claude` via `os.execvpe`.

---

## License

[MIT](./LICENSE)
