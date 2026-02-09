#!/bin/bash
# Secure OpenClaw Setup Script
# Run this after cloning the config repo

set -e

echo "================================================"
echo "  Secure OpenClaw Setup"
echo "================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Step 1: Create directories
echo -e "${YELLOW}[1/5]${NC} Creating secure directories..."
mkdir -p ~/.openclaw/agents/research-agent/agent
mkdir -p ~/.openclaw/credentials
mkdir -p ~/.openclaw/workspace
mkdir -p ~/.openclaw/logs
chmod 700 ~/.openclaw ~/.openclaw/credentials ~/.openclaw/workspace ~/.openclaw/logs
echo -e "${GREEN}✓${NC} Directories created with secure permissions"

# Step 2: Generate token
echo ""
echo -e "${YELLOW}[2/5]${NC} Generating auth token..."
TOKEN=$(openssl rand -hex 32)
echo -e "${GREEN}✓${NC} Token generated"

# Step 3: Copy and configure files
echo ""
echo -e "${YELLOW}[3/5]${NC} Copying configuration files..."

# Copy openclaw.json and replace token placeholder
sed "s/REPLACE_WITH_OUTPUT_OF_openssl_rand_-hex_32/$TOKEN/" \
    "$SCRIPT_DIR/config/openclaw.json" > ~/.openclaw/openclaw.json

# Copy env template and add token
cp "$SCRIPT_DIR/config/env.template" ~/.openclaw/.env
echo "" >> ~/.openclaw/.env
echo "# Auto-generated token (matches openclaw.json)" >> ~/.openclaw/.env
echo "OPENCLAW_GATEWAY_TOKEN=$TOKEN" >> ~/.openclaw/.env
chmod 600 ~/.openclaw/.env

# Copy agent SOUL file
cp -r "$SCRIPT_DIR/agents/"* ~/.openclaw/agents/

echo -e "${GREEN}✓${NC} Configuration files installed"

# Step 4: Create Docker network
echo ""
echo -e "${YELLOW}[4/5]${NC} Creating isolated Docker network..."
docker network create --internal openclaw-isolated 2>/dev/null || echo "Network already exists"
echo -e "${GREEN}✓${NC} Docker network ready"

# Step 5: Copy scripts
echo ""
echo -e "${YELLOW}[5/5]${NC} Installing scripts..."
mkdir -p ~/openclaw-sandbox
cp "$SCRIPT_DIR/scripts/kill-agent.sh" ~/openclaw-sandbox/
cp "$SCRIPT_DIR/scripts/verify-security.sh" ~/openclaw-sandbox/
chmod +x ~/openclaw-sandbox/*.sh
echo -e "${GREEN}✓${NC} Scripts installed"

echo ""
echo "================================================"
echo -e "${GREEN}  Setup Complete!${NC}"
echo "================================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Create a Telegram bot:"
echo "   - Message @BotFather on Telegram"
echo "   - Send /newbot and follow prompts"
echo "   - Save the bot token"
echo ""
echo "2. Get your Telegram user ID:"
echo "   - Message @userinfobot on Telegram"
echo ""
echo "3. Add your credentials:"
echo "   - Edit ~/.openclaw/.env → add TELEGRAM_BOT_TOKEN"
echo "   - Edit ~/.openclaw/openclaw.json → add your user ID to allowFrom"
echo ""
echo "4. Start the agent:"
echo "   cd ~/openclaw-sandbox/openclaw"
echo "   docker compose up -d openclaw-gateway"
echo ""
echo "5. Add Telegram channel:"
echo "   docker compose run --rm openclaw-cli channels add --channel telegram --token YOUR_TOKEN"
echo ""
echo "6. Verify security:"
echo "   ~/openclaw-sandbox/verify-security.sh"
echo ""
