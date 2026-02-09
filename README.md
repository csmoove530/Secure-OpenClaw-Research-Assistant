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
- Copy configuration files
- Create the isolated Docker network

### 3. Add Your Telegram Bot

```bash
# Get your bot token from @BotFather on Telegram
# Get your user ID from @userinfobot on Telegram

# Then run:
cd ~/openclaw-sandbox/openclaw
docker compose run --rm openclaw-cli channels add --channel telegram --token YOUR_BOT_TOKEN
```

Edit `~/.openclaw/openclaw.json` and add your Telegram user ID:
```json
"allowFrom": ["YOUR_TELEGRAM_USER_ID"]
```

### 4. Start and Verify

```bash
# Start the agent
docker compose up -d openclaw-gateway

# Verify security (should show 15 passed)
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

| Task | Command |
|------|---------|
| Start agent | `cd ~/openclaw-sandbox/openclaw && docker compose up -d` |
| Stop agent | `docker compose down` |
| **Emergency kill** | `~/openclaw-sandbox/kill-agent.sh` |
| View logs | `docker compose logs -f openclaw-gateway` |
| Security audit | `docker compose exec openclaw-gateway node dist/index.js security audit --deep` |

---

## Agent Capabilities

### What It Can Do
- Read documents you provide
- Summarize and analyze text
- Answer questions
- Draft responses for your review

### What It Cannot Do (Hardcoded)
- Access files or filesystem
- Make network requests
- Execute code
- Install plugins
- Access credentials
- Send messages without your review

---

## Troubleshooting

### Container won't start

**Symptom:** `docker compose up` exits immediately

**Check logs:**
```bash
docker compose logs openclaw-gateway
```

**Common causes:**
- Invalid JSON in `~/.openclaw/openclaw.json` → Validate with `jq . ~/.openclaw/openclaw.json`
- Missing `gateway.mode` → Ensure config has `"mode": "local"`

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

---

## Security Model

This configuration implements defense-in-depth:

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR MACHINE                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │              DOCKER CONTAINER                     │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │           OPENCLAW SANDBOX                  │  │  │
│  │  │  ┌───────────────────────────────────────┐  │  │  │
│  │  │  │         RESEARCH AGENT               │  │  │  │
│  │  │  │    (read-only, no network)           │  │  │  │
│  │  │  └───────────────────────────────────────┘  │  │  │
│  │  │  • network: none                            │  │  │
│  │  │  • readOnlyRoot: true                       │  │  │
│  │  │  • capDrop: ALL                             │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │  • loopback only                                  │  │
│  │  • token auth                                     │  │
│  └───────────────────────────────────────────────────┘  │
│  • Telegram allowlist                                   │
│  • Kill switch ready                                    │
└─────────────────────────────────────────────────────────┘
```

### Why This Matters

OpenClaw has known vulnerabilities:
- **CVE-2025-49596**, **CVE-2025-6514**
- 30,000+ exposed instances on Shodan
- Malicious skills via ClawHub
- Prompt injection risks

This config blocks all attack vectors by removing capabilities entirely.

---

## File Reference

```
~/.openclaw/
├── openclaw.json          # Main config
├── .env                   # Secrets (chmod 600)
└── agents/
    └── research-agent/
        └── agent/
            └── soul.md    # Agent restrictions

~/openclaw-sandbox/
├── openclaw/              # OpenClaw source
├── kill-agent.sh          # Emergency stop
└── verify-security.sh     # Security checks
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

</details>

---

## Contributing

Security improvements welcome. Open an issue first.

## License

MIT (configuration files only)
