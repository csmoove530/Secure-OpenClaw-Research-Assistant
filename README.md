# Secure OpenClaw Research Assistant

Maximum isolation configuration for running OpenClaw as a **read-only research assistant** in a hardened Docker sandbox.

## Security Context

OpenClaw has documented vulnerabilities and risks:
- **CVE-2025-49596**, **CVE-2025-6514** - Known critical vulnerabilities
- Malicious skills distributed via ClawHub
- Prompt injection through ingested content
- No mandatory human-in-the-loop by default
- Over 30,000 exposed instances found on Shodan

This configuration mitigates these risks through defense-in-depth.

## Security Features

### Network Isolation
- Gateway bound to `loopback` only (no external network exposure)
- Docker sandbox runs with `network: none` (complete network isolation)
- mDNS discovery disabled

### Container Hardening
- Read-only root filesystem (`readOnlyRoot: true`)
- All Linux capabilities dropped (`capDrop: ["ALL"]`)
- Memory limits enforced (512MB)
- Process limits enforced (256 PIDs max)
- Non-root user execution (`user: 1000:1000`)

### Access Control
- Token-based gateway authentication
- Telegram allowlist - only specified user IDs can interact
- Group policy set to allowlist (blocks group messages)

### Agent Restrictions
- Strict session-scoped sandbox
- No workspace filesystem access
- SOUL file with hardcoded security prohibitions

## File Structure

```
.
├── config/
│   ├── openclaw.json      # Main config (copy to ~/.openclaw/)
│   └── env.template       # Secrets template (copy to ~/.openclaw/.env)
├── agents/
│   └── research-agent/
│       └── agent/
│           └── soul.md    # Agent directives with security constraints
├── scripts/
│   ├── kill-agent.sh      # Emergency stop script
│   └── verify-security.sh # Security verification checks
└── README.md
```

## Installation

### Prerequisites
- Docker Desktop installed
- Telegram account (for bot creation)

### Steps

1. **Clone OpenClaw**
   ```bash
   mkdir -p ~/openclaw-sandbox
   cd ~/openclaw-sandbox
   git clone https://github.com/openclaw/openclaw.git
   cd openclaw
   docker build -t openclaw:local -f Dockerfile .
   ```

2. **Create config directory**
   ```bash
   mkdir -p ~/.openclaw/agents/research-agent/agent
   mkdir -p ~/.openclaw/credentials
   mkdir -p ~/.openclaw/workspace
   chmod 700 ~/.openclaw ~/.openclaw/credentials ~/.openclaw/workspace
   ```

3. **Generate auth token**
   ```bash
   openssl rand -hex 32
   # Save this - you'll need it for config and .env
   ```

4. **Copy configuration files**
   ```bash
   cp config/openclaw.json ~/.openclaw/
   cp config/env.template ~/.openclaw/.env
   cp -r agents/* ~/.openclaw/agents/
   chmod 600 ~/.openclaw/.env
   ```

5. **Edit configuration**
   - Replace `REPLACE_WITH_OUTPUT_OF_openssl_rand_-hex_32` in `~/.openclaw/openclaw.json` with your generated token
   - Fill in your actual values in `~/.openclaw/.env`

6. **Create Telegram bot**
   - Message @BotFather on Telegram
   - Send `/newbot` and follow prompts
   - Save the bot token
   - Add token to `~/.openclaw/.env`

7. **Get your Telegram user ID**
   - Message @userinfobot on Telegram
   - Add your ID to `allowFrom` array in `~/.openclaw/openclaw.json`

8. **Create isolated network**
   ```bash
   docker network create --internal openclaw-isolated
   ```

9. **Copy scripts**
   ```bash
   cp scripts/*.sh ~/openclaw-sandbox/
   chmod +x ~/openclaw-sandbox/*.sh
   ```

10. **Verify security configuration**
    ```bash
    ~/openclaw-sandbox/verify-security.sh
    ```

11. **Start the gateway**
    ```bash
    cd ~/openclaw-sandbox/openclaw
    docker compose up -d openclaw-gateway
    ```

12. **Add Telegram channel**
    ```bash
    docker compose run --rm openclaw-cli channels add --channel telegram --token YOUR_BOT_TOKEN
    ```

13. **Run security audit**
    ```bash
    docker compose exec openclaw-gateway node dist/index.js security audit --deep
    ```

## Usage

### Start Agent
```bash
cd ~/openclaw-sandbox/openclaw
docker compose up -d openclaw-gateway
```

### Stop Agent
```bash
docker compose down
```

### Emergency Kill
```bash
~/openclaw-sandbox/kill-agent.sh
```

### Monitor Logs
```bash
docker compose logs -f openclaw-gateway
```

### Run Security Audit
```bash
docker compose exec openclaw-gateway node dist/index.js security audit --deep
```

## Agent Capabilities

The research assistant is configured for **READ-ONLY** operation:

### Permitted
- Read documents provided in conversation
- Summarize and analyze text
- Answer questions about provided materials
- Explain concepts
- Draft text for human review

### Prohibited (Hardcoded in SOUL file)
- Financial transactions
- Credential access/storage
- File system operations
- Network requests
- External communications
- Skill/plugin installation
- Sandbox escape attempts

## Security Verification

Run the verification script to check your configuration:

```bash
~/openclaw-sandbox/verify-security.sh
```

Expected output: **15 passed, 0 failed**

## Warnings

- **Never commit `.env` files** with real credentials
- **Never expose the gateway** beyond loopback
- **Review all agent interactions** - this is a research tool
- **Keep OpenClaw updated** for security patches
- **Test the kill switch** before relying on it

## Contributing

Security improvements welcome. Please open an issue to discuss before submitting PRs.

## License

MIT - Configuration files only. OpenClaw itself has its own license.
