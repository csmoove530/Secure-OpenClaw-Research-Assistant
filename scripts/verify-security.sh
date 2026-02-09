#!/bin/bash
# OpenClaw Security Verification Script
# Run this before starting the agent to verify security configuration

echo "================================================"
echo "  OpenClaw Security Verification"
echo "================================================"
echo ""

PASS=0
FAIL=0

check() {
    if [ $1 -eq 0 ]; then
        echo "[PASS] $2"
        ((PASS++))
    else
        echo "[FAIL] $2"
        ((FAIL++))
    fi
}

# Check config file exists
test -f ~/.openclaw/openclaw.json
check $? "Config file exists"

# Check gateway is loopback only
grep -q '"bind": "loopback"' ~/.openclaw/openclaw.json
check $? "Gateway bound to loopback only"

# Check network is disabled in sandbox
grep -q '"network": "none"' ~/.openclaw/openclaw.json
check $? "Docker sandbox network disabled"

# Check ClawHub is disabled
grep -q '"clawhub": { "enabled": false }' ~/.openclaw/openclaw.json
check $? "ClawHub registry disabled"

# Check MCP is disabled
grep -q '"mcp": {' ~/.openclaw/openclaw.json && grep -q '"enabled": false' ~/.openclaw/openclaw.json
check $? "MCP servers disabled"

# Check read-only root
grep -q '"readOnlyRoot": true' ~/.openclaw/openclaw.json
check $? "Docker read-only root filesystem"

# Check all capabilities dropped
grep -q '"capDrop": \["ALL"\]' ~/.openclaw/openclaw.json
check $? "All Docker capabilities dropped"

# Check SOUL file exists
test -f ~/.openclaw/agents/research-agent/agent/soul.md
check $? "Agent SOUL file exists"

# Check SOUL file has security prohibitions
grep -q "ABSOLUTE PROHIBITIONS" ~/.openclaw/agents/research-agent/agent/soul.md
check $? "SOUL file contains security prohibitions"

# Check credentials directory permissions
stat -f "%OLp" ~/.openclaw/credentials 2>/dev/null | grep -q "700"
check $? "Credentials directory has secure permissions (700)"

# Check .env file permissions
stat -f "%OLp" ~/.openclaw/.env 2>/dev/null | grep -q "600"
check $? ".env file has secure permissions (600)"

# Check isolated network exists
docker network ls | grep -q "openclaw-isolated"
check $? "Isolated Docker network exists"

# Check kill switch exists and is executable
test -x ~/openclaw-sandbox/kill-agent.sh
check $? "Kill switch script exists and is executable"

# Check telemetry is disabled
grep -q '"telemetry": {' ~/.openclaw/openclaw.json && grep -q '"enabled": false' ~/.openclaw/openclaw.json
check $? "Telemetry disabled"

# Check plugins disabled
grep -q '"plugins": {' ~/.openclaw/openclaw.json
check $? "Plugins configuration exists (should be disabled)"

echo ""
echo "================================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "================================================"

if [ $FAIL -gt 0 ]; then
    echo ""
    echo "WARNING: Some security checks failed!"
    echo "Review the configuration before starting the agent."
    exit 1
else
    echo ""
    echo "All security checks passed."
    echo "The agent is configured for maximum isolation."
fi
