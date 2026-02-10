# Secure OpenClaw Research Assistant

Run OpenClaw as a **read-only research assistant** in maximum isolation mode.

```bash
# Quick start (after cloning this repo)
./scripts/setup.sh
```

---

## Quick Start

### 1. Clone and Build

```bash
# Clone this config repo
git clone https://github.com/csmoove530/Secure-OpenClaw-Research-Assistant.git
cd Secure-OpenClaw-Research-Assistant

# Clone and build OpenClaw
mkdir -p ~/openclaw-sandbox && cd ~/openclaw-sandbox
git clone https://github.com/openclaw/openclaw.git
cd openclaw && docker build -t openclaw:local -f Dockerfile .
```

### 2. Run Setup Script

```bash
cd ~/Secure-OpenClaw-Research-Assistant
./scripts/setup.sh
```

This script will:
- Create secure directories with proper permissions
- Generate your auth token
- Copy configuration files (including hardened docker-compose)
- Create the isolated Docker network

### 3. Add Your Telegram Bot

```bash
# Get your bot token from @BotFather on Telegram
# Get your user ID from @userinfobot on Telegram

# Then run:
cd ~/openclaw-sandbox/openclaw
docker compose -f docker-compose.yml -f docker-compose.hardened.yml \
  run --rm openclaw-cli channels add --channel telegram --token YOUR_BOT_TOKEN
```

Edit `~/.openclaw/openclaw.json` and add your Telegram user ID:
```json
"allowFrom": ["YOUR_TELEGRAM_USER_ID"]
```

### 4. Start with Hardened Compose

```bash
cd ~/openclaw-sandbox/openclaw

# Start with security hardening overlay
docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d

# Verify security
~/openclaw-sandbox/verify-security.sh

# Run security audit
docker compose exec openclaw-gateway node dist/index.js security audit --deep
```

**Expected output:**
```
OpenClaw security audit
Summary: 0 critical · 3 warn · 1 info
```

### 5. Test It

Message your bot on Telegram. It should respond as a read-only research assistant.

---

## What Success Looks Like

After setup, you should see:

**Security verification:**
```
================================================
  OpenClaw Security Verification
================================================

[PASS] Config file exists
[PASS] Gateway bound to loopback only
[PASS] Docker sandbox network disabled
[PASS] ClawHub registry disabled
...
================================================
  Results: 15 passed, 0 failed
================================================
```

**Security audit:**
```
Summary: 0 critical · 3 warn · 1 info

Attack surface:
  - Groups: open=0, allowlist=1
```

The 3 warnings are expected for maximum isolation mode.

---

## Common Commands

**Important:** Always use the hardened compose overlay:

```bash
# Set alias for convenience (add to ~/.bashrc or ~/.zshrc)
alias openclaw-compose='docker compose -f docker-compose.yml -f docker-compose.hardened.yml'
```

| Task | Command |
|------|---------|
| Start agent | `openclaw-compose up -d` |
| Stop agent | `openclaw-compose down` |
| **Emergency kill** | `~/openclaw-sandbox/kill-agent.sh` |
| View logs | `openclaw-compose logs -f openclaw-gateway` |
| Security audit | `openclaw-compose exec openclaw-gateway node dist/index.js security audit --deep` |

---

## Security Model

### Understanding Security Boundaries

This configuration has two types of controls:

| Layer | Type | Bypass Difficulty |
|-------|------|-------------------|
| Container isolation | **HARD BOUNDARY** | Requires container escape exploit |
| Capability dropping | **HARD BOUNDARY** | Kernel-enforced |
| Seccomp filtering | **HARD BOUNDARY** | Kernel-enforced |
| no-new-privileges | **HARD BOUNDARY** | Kernel-enforced |
| Network isolation | **HARD BOUNDARY** | Requires container escape |
| Read-only filesystem | **HARD BOUNDARY** | Kernel-enforced |
| SOUL file directives | **SOFT CONTROL** | Bypassable via prompt injection |
| Telegram allowlist | **MEDIUM** | Requires stealing your Telegram session |

**Critical:** The SOUL file (`soul.md`) provides behavioral guidance but is **NOT a security boundary**. It can be bypassed by prompt injection - the exact attack this setup defends against. Real security comes from the container-level restrictions.

### Defense-in-Depth Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      YOUR MACHINE                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           DOCKER CONTAINER (HARD BOUNDARY)            │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │              SECURITY CONTROLS                  │  │  │
│  │  │  • no-new-privileges: true                      │  │  │
│  │  │  • seccomp: restricted syscalls                 │  │  │
│  │  │  • capabilities: ALL dropped                    │  │  │
│  │  │  • read_only: true                              │  │  │
│  │  │  • user: 1000:1000 (non-root)                   │  │  │
│  │  │  • pids_limit: 256                              │  │  │
│  │  │  • memory: 512MB max                            │  │  │
│  │  │  • cpus: 1.0 max                                │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │           OPENCLAW SANDBOX                      │  │  │
│  │  │  • network: none (no egress)                    │  │  │
│  │  │  • workspaceAccess: none                        │  │  │
│  │  │  • scope: session                               │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │           AGENT (SOFT CONTROLS)                 │  │  │
│  │  │  • SOUL file behavioral restrictions            │  │  │
│  │  │  • (can be bypassed by prompt injection)        │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  │                                                       │  │
│  │  Gateway: loopback only + token auth                  │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  Telegram: allowlist (only your user ID)                    │
│  Kill switch: ~/openclaw-sandbox/kill-agent.sh              │
└─────────────────────────────────────────────────────────────┘
```

### What the Hardened Compose Adds

The `docker-compose.hardened.yml` overlay adds protections missing from upstream:

| Protection | What It Does |
|------------|--------------|
| `no-new-privileges` | Prevents setuid/setgid privilege escalation |
| `seccomp` profile | Filters dangerous syscalls at kernel level |
| `cpu` limits | Prevents DoS via CPU exhaustion (1 core max) |
| `memory` limits | Prevents DoS via memory exhaustion (512MB max) |
| `read_only: true` | Immutable root filesystem |
| `tmpfs` with noexec | Writable temp dirs can't execute code |
| `pids_limit` | Prevents fork bombs |

---

## Agent Capabilities

### What It Can Do
- Read documents you provide
- Summarize and analyze text
- Answer questions
- Draft responses for your review

### What It Cannot Do

**Enforced by container (HARD):**
- Access host filesystem
- Make network connections
- Spawn unlimited processes
- Consume unlimited resources
- Escalate privileges

**Requested by SOUL file (SOFT - can be bypassed):**
- Financial transactions
- Credential handling
- External communications

---

## Troubleshooting

### Container won't start

**Symptom:** `docker compose up` exits immediately

**Check logs:**
```bash
docker compose -f docker-compose.yml -f docker-compose.hardened.yml logs openclaw-gateway
```

**Common causes:**
- Invalid JSON in `~/.openclaw/openclaw.json` → Validate with `jq . ~/.openclaw/openclaw.json`
- Missing `gateway.mode` → Ensure config has `"mode": "local"`
- Resource limits too tight → Check if 512MB is enough for your use

### Security verification fails

**Symptom:** `verify-security.sh` shows failures

**Fix permissions:**
```bash
chmod 700 ~/.openclaw ~/.openclaw/credentials ~/.openclaw/workspace
chmod 600 ~/.openclaw/.env
```

### Bot doesn't respond

**Symptom:** Messages to Telegram bot get no response

**Check:**
1. Bot token is correct in `.env`
2. Your user ID is in `allowFrom` array
3. Gateway is running: `docker compose ps`
4. Logs for errors: `docker compose logs -f`

### "Config invalid" errors

**Symptom:** Logs show config validation errors

**Run doctor:**
```bash
docker compose exec openclaw-gateway node dist/index.js doctor --fix
```

### Resource limit errors

**Symptom:** Container OOM killed or CPU throttled

**Adjust limits** in `docker-compose.hardened.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'      # Increase if needed
      memory: 1024M    # Increase if needed
```

---

## File Reference

```
This repo:
├── docker-compose.hardened.yml  # Security overlay (IMPORTANT)
├── config/
│   ├── openclaw.json            # Main config
│   ├── env.template             # Secrets template
│   └── seccomp-profile.json     # Syscall filter (optional)
├── agents/
│   └── research-agent/
│       └── agent/
│           └── soul.md          # Agent behavioral guidance
└── scripts/
    ├── setup.sh                 # Automated setup
    ├── kill-agent.sh            # Emergency stop
    └── verify-security.sh       # Security checks

After setup:
~/.openclaw/
├── openclaw.json                # Your config (with real token)
├── .env                         # Your secrets (chmod 600)
└── agents/...

~/openclaw-sandbox/openclaw/
├── docker-compose.yml           # Upstream compose
├── docker-compose.hardened.yml  # Copied hardening overlay
└── ...
```

---

## Manual Installation

<details>
<summary>Click to expand step-by-step instructions</summary>

If you prefer manual setup over the setup script:

### Create directories
```bash
mkdir -p ~/.openclaw/agents/research-agent/agent
mkdir -p ~/.openclaw/credentials ~/.openclaw/workspace
chmod 700 ~/.openclaw ~/.openclaw/credentials ~/.openclaw/workspace
```

### Generate token
```bash
TOKEN=$(openssl rand -hex 32)
echo "Your token: $TOKEN"
```

### Copy files
```bash
cp config/openclaw.json ~/.openclaw/
cp config/env.template ~/.openclaw/.env
cp -r agents/* ~/.openclaw/agents/
cp docker-compose.hardened.yml ~/openclaw-sandbox/openclaw/
chmod 600 ~/.openclaw/.env
```

### Edit config
Replace `REPLACE_WITH_OUTPUT_OF_openssl_rand_-hex_32` in both:
- `~/.openclaw/openclaw.json`
- `~/.openclaw/.env`

### Create network
```bash
docker network create --internal openclaw-isolated
```

### Copy scripts
```bash
cp scripts/*.sh ~/openclaw-sandbox/
chmod +x ~/openclaw-sandbox/*.sh
```

### Start with hardening
```bash
cd ~/openclaw-sandbox/openclaw
docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d
```

</details>

---

## Why This Matters

OpenClaw has known vulnerabilities:
- **CVE-2025-49596**, **CVE-2025-6514**
- 30,000+ exposed instances on Shodan
- Malicious skills via ClawHub
- Prompt injection attacks

This configuration assumes the agent **will be compromised** via prompt injection and ensures that a compromised agent **cannot escape the container** or affect your system.

---

## Contributing

Security improvements welcome. Open an issue first.

## License

MIT (configuration files only)
