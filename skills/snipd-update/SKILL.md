---
name: snipd-update
description: Use when the user asks to update or upgrade Snipd or the Snipd plugin, asks whether their Snipd plugin is current, wonders why a Snipd tool or skill the docs mention is missing, or wants Snipd to keep itself up to date (auto-update).
compatibility: Updates the locally installed Snipd plugin. The Snipd MCP server itself is remote and always current.
---

# Keep Snipd up to date

The Snipd **MCP server** is remote, so its tools are always current — nothing to update there.
What goes stale is the locally installed **plugin**: these skills, and the MCP server entry they
add. A new commit alone never updates it; only a new `version` in the plugin manifest does.

Claude Code can pick new versions up on its own once the user turns auto-update on.
**Codex has no auto-update at all** and always needs the command run by hand.

Run the section for the agent you are.

## Claude Code

The marketplace key is whatever name it was added under — usually `snipd-app`, but older
installs are keyed `snipd`. Never hardcode it; read it first:

```bash
claude plugin marketplace list
```

### Update now

With `<key>` from that list:

```bash
claude plugin marketplace update <key>
claude plugin update snipd@<key>
```

Then have the user run `/reload-plugins` (or restart Claude Code) so the new version loads.
If `/reload-plugins` warns that it would re-read the conversation, they can rerun it as
`/reload-plugins --force` or just leave it for the next launch.

### Offer auto-update

Auto-update is **off by default for third-party marketplaces** like Snipd, so unless the user
turned it on, they only ever get new versions by running the commands above. Offer it once —
ask, don't assume, since this changes settings on their machine:

> Snipd can keep itself up to date — Claude Code would check for a new version shortly after
> each session starts and update it in the background. Want me to turn that on?

If they say yes, enable it:

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home() / ".claude/plugins/known_marketplaces.json"
d = json.loads(p.read_text())
keys = [k for k, v in d.items()
        if "snipd-mcp" in json.dumps(v).lower() or k in ("snipd", "snipd-app")]
if not keys:
    raise SystemExit("No Snipd marketplace found — add it first (see the snipd-connect skill).")
for k in keys:
    d[k]["autoUpdate"] = True
p.write_text(json.dumps(d, indent=2))
print("auto-update enabled for: " + ", ".join(keys))
PY
```

That writes the same setting the interactive toggle does. If it fails, or the user would rather
click it themselves, give them the equivalent path instead:

> `/plugin` → **Marketplaces** → select the Snipd marketplace → **Enable auto-update**

Tell them what to expect: it takes effect from their **next** session, where Claude Code checks
within about ten minutes of startup and updates the plugin on disk. When an update lands they
get a prompt to run `/reload-plugins`; otherwise it loads at the following launch.

If they say no, leave it — just mention they can run this skill again whenever they want to update.

## Codex

Codex never refreshes a user-added marketplace on its own, so this is the only way to get a new
version:

```bash
codex plugin marketplace upgrade snipd-app
```

Then start a new session or thread so the refreshed skills load. Notes:

- Use the name the marketplace was added under if it differs; `codex plugin marketplace list`
  shows it, and omitting the name upgrades every Git marketplace.
- `upgrade` only refreshes **Git** marketplaces. One added from a local path always reads that
  directory, so there is nothing to pull.
- If the marketplace is not configured yet:
  `codex plugin marketplace add snipd-app/snipd-mcp`
- If an upgrade seems not to take, `codex plugin add snipd@snipd-app` force-reinstalls it.

There is no auto-update setting to offer in Codex. If the user asks for one, say so plainly and
suggest they run this skill now and then.

## Cursor and other MCP clients

These connect straight to the remote server, so they are always current. Nothing to update.
