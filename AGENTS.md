# Public repository publishing

This repository is public. Local feature branches and edits are allowed.
Do not push, publish, or create a pull request without explicit human permission for
`snipd-mcp`. A general request to create PRs is insufficient: ask separately
whether it includes this public repository.

# Maintaining the plugin

The README is public and for users; keep maintainer notes here.

Clients only pick up a new plugin version when `version` changes in `.claude-plugin/plugin.json`,
`.codex-plugin/plugin.json` and `plugin.json`; bump all three in the same commit as the change.

## Repository layout

| Path | Used by |
|---|---|
| `.mcp.json` | The MCP server both plugins install (Claude Code and Codex read the same `mcpServers` shape) |
| `plugin.json`, `mcp.json` | The same plugin in the portable [Agent Plugins](https://agent-plugins.org) format that OpenAI's plugin directory (ChatGPT and Codex) reads: `mcp.json` declares the server as `streamable-http` with OAuth (dynamic client registration) and `plugin.json` carries the listing (`extensions.com.openai.interface`). Keep its `interface` identical to the one in `.codex-plugin/plugin.json`: when both exist, the root one wins |
| `LICENSE` | MIT. Anthropic's directory requires a license file |
| `justfile` | `just validate` checks the plugin; `just package-openai` builds the ZIP for OpenAI's plugin submission portal |
| `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | Claude Code plugin and its marketplace. The manifest also carries the Anthropic directory listing fields (`icon`, `documentationUrl`, `supportUrl`, `privacyPolicyUrl`, `termsOfServiceUrl`) |
| `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json` | Codex plugin and its marketplace |

## Development

The plugin ships no skills: the MCP server's own instructions and tool descriptions cover how to use it.
If skills come back, ship at least two. Codex gives a plugin its own skill root only when the
plugin ships two or more skills (`shared_host_alias_roots` in `codex-rs/ext/skills/src/host_aliases.rs`);
with a single skill the model must expand `<marketplace>/<plugin>/<version>/skills/<skill>/SKILL.md`
itself and reliably drops a segment, so every session starts with a failed read.

Run `just validate` before a release: it runs `claude plugin validate . --strict --profile directory` and checks that the
three manifest versions match and that the OpenAI `interface` is the same in `plugin.json` and `.codex-plugin/plugin.json`.
Try the Claude Code plugin with `claude --plugin-dir .`. Inside a checkout, Codex discovers the marketplace automatically; elsewhere
`codex plugin marketplace add /path/to/snipd-mcp` then `codex plugin add snipd@snipd-app`.

## Submitting to OpenAI's plugin directory

The [submission portal](https://developers.openai.com/plugins/deploy/submission) takes a ZIP with the
portable plugin at its root. Build it from the committed files with `just package-openai`; it runs `just validate` first, writes
`dist/snipd-openai-plugin-<version>.zip` and refuses to run while the packaged files have uncommitted changes.

The review's test cases (exactly five positive and three negative) live in `plugin.json` under
`extensions.com.openai.review` and are read-only in the portal; change them there and upload again. The
reviewer's test account and the demo recording URL go in the portal's form, never in the ZIP.
