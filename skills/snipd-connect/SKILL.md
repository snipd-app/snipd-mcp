---
name: snipd-connect
description: Use when the user asks to connect Snipd to this agent, or when the Snipd tools (account_whoami, snips_list, subscriptions_list, queue_list, ...) are missing and the Snipd MCP server must be added and signed in before the snipd or queue skills can be used.
compatibility: Adds the remote Snipd MCP server to the current agent; the user signs in with their Snipd account in the browser.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Connect Snipd

Server URL: `https://mcp.snipd.com/mcp` (OAuth is discovered
automatically; the user signs in with their Snipd account in the browser).

| Agent | Command |
|---|---|
| Claude Code | `claude mcp add --transport http --scope user snipd https://mcp.snipd.com/mcp`, then `/mcp` → `snipd` → **Authenticate** |
| Codex | `codex mcp add snipd --url https://mcp.snipd.com/mcp` (the sign-in opens by itself; otherwise `codex mcp login snipd`) |
| Cursor and other MCP clients | add `{"mcpServers": {"snipd": {"url": "https://mcp.snipd.com/mcp"}}}` to the client's MCP config, then sign in when prompted |

Run the command for the agent you are. Adding the server only *installs* it — the `snipd`
tools stay unavailable until the user has signed in, so treat the setup as unfinished
until authentication actually succeeds:

- Keep the login command running while the user completes it. Do not background it or
  move on to other work.
- If the browser does not open (Codex reports "Browser launch failed"), show the user the
  OAuth URL it printed and ask them to open it. Sign-in needs their Snipd credentials and
  their consent, so it cannot be completed on their behalf.
- Then confirm the client reports the server as connected — or just call `account_whoami` —
  before telling the user Snipd is ready.

## Then offer to keep it up to date

Setup is the one moment the user is already configuring Snipd, so raise updates once here —
briefly, and only after the sign-in actually succeeded. What you say depends on the agent:

- **Claude Code:** auto-update is off by default for third-party plugins like Snipd. Ask whether
  they want it on ("Snipd can keep itself up to date — want me to turn that on?") and, if they
  say yes, follow the *Offer auto-update* section of the `snipd-update` skill to enable it.
- **Codex:** there is no auto-update. Mention in one line that new versions arrive via
  `codex plugin marketplace upgrade snipd-app`, or the `snipd-update` skill.
- **Cursor and other MCP clients:** nothing to say — they use the remote server directly and are
  always current.

Ask once and accept the answer. Do not enable anything without the user agreeing, and do not
re-raise it later in the conversation if they decline.

Once the tools are available, follow the `snipd` skill to work with the user's podcasts (snips, subscriptions, shows,
episodes, feeds, history) and the `queue` skill for their play queue.
