---
name: remember-feedback
description: Save user feedback and preferences to persistent memory. Triggers on "remember", "going forward", "quick feedback", "from now on", "always do", "never do", "I prefer".
metadata: { "openclaw": { "emoji": "🧠", "autoTrigger": true } }
---

# Remember Feedback Skill

When the user provides feedback using trigger phrases, extract and save it to the persistent soul.md file.

## Trigger Phrases
Activate this skill when the user's message contains:
- "remember that..."
- "going forward..."
- "quick feedback:"
- "from now on..."
- "always do..."
- "never do..."
- "I prefer..."
- "here's some feedback"
- "note for future"

## Action

1. **Extract the feedback** from the user's message
2. **Categorize it** into one of these sections:
   - `Writing Style Guidelines` - formatting, tone, structure preferences
   - `Data & Dashboard Preferences` - how to present data, charts, numbers
   - `Things to Avoid` - anti-patterns, mistakes to not repeat
   - `General Preferences` - other preferences

3. **Append to soul.md** using this exact command:

```bash
# First, read current content to avoid duplicates
cat /home/node/.openclaw/agents/main/agent/soul.md

# Then append the new feedback with timestamp
cat >> /home/node/.openclaw/agents/main/agent/soul.md << 'FEEDBACK'

### [CATEGORY] - Added [DATE]
- [EXTRACTED FEEDBACK]
FEEDBACK
```

4. **Confirm to the user** what was saved

## Example

User: "Going forward, when showing financial data always include the currency symbol and use 2 decimal places"

Action:
```bash
cat >> /config/agents/main/agent/soul.md << 'FEEDBACK'

### Data & Dashboard Preferences - Added 2026-02-10
- When showing financial data, always include the currency symbol and use 2 decimal places
FEEDBACK
```

Response: "Got it! I've saved this preference: 'When showing financial data, always include the currency symbol and use 2 decimal places'. I'll follow this going forward."

## Important Notes
- The soul.md file is at `/home/node/.openclaw/agents/main/agent/soul.md` inside the container
- This maps to `~/.openclaw/agents/main/agent/soul.md` on the host
- Always read the file first to check for duplicate feedback
- Use clear, actionable language when saving
