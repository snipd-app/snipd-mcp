# Snipd for Claude Code, Codex and other agents

Connect your coding agent to your [Snipd](https://www.snipd.com) account and let it work with your
podcasts: read, delete and tag your snips and notes, browse and manage the shows you follow, open episodes (details,
transcripts and AI snips), see your feeds and listen history, control your play queue, and upload your
own audio. This repository is the official install kit for the Snipd MCP server: a Claude Code
plugin, a Codex plugin and six [Agent Skills](https://agentskills.io) that teach the agent what the
tools do and how to use them.

The server is remote (nothing runs on your machine). Browsing never changes your account. Four
things do, and the skills make the agent confirm with you first: deleting or tagging snips,
subscribing and unsubscribing, changing the play queue (your devices pick it up within seconds), and
uploads, which add episodes.
You sign in with your Snipd account in the browser; disconnecting in your agent revokes its access.

- MCP endpoint: `https://mcp.snipd.com/mcp`
- Sign-in: `https://auth.snipd.com` (OAuth 2.1, discovered automatically by every client below)

## Install

### Claude Code

Plugin (adds the server and the skills, keeps them updated):

```bash
claude plugin marketplace add snipd-app/snipd-mcp
claude plugin install snipd@snipd-app
```

Then run `/mcp` inside Claude Code, pick `snipd` and choose **Authenticate**.

Server only, without the plugin:

```bash
claude mcp add --transport http --scope user snipd https://mcp.snipd.com/mcp
```

### Codex (CLI, IDE extension and the ChatGPT desktop app share this)

Plugin:

```bash
codex plugin marketplace add snipd-app/snipd-mcp
codex plugin add snipd@snipd-app
```

Server only:

```bash
codex mcp add snipd --url https://mcp.snipd.com/mcp
```

The sign-in opens in your browser. If it does not, run `codex mcp login snipd`.

### Cursor, Gemini CLI, GitHub Copilot and other MCP clients

Skills only (the `snipd-connect` skill tells the agent how to add the server for your client):

```bash
npx skills add snipd-app/snipd-mcp
```

Or add the server by hand to your client's MCP configuration:

```json
{ "mcpServers": { "snipd": { "url": "https://mcp.snipd.com/mcp" } } }
```

### claude.ai and Claude Desktop

Settings → Connectors → **Add custom connector** → URL
`https://mcp.snipd.com/mcp`.

### ChatGPT

Settings → Security and login → **Developer mode**, then create a connector with the MCP URL
above. Available on Plus, Pro, Business, Enterprise and Edu plans (web).

## What the agent can do

| Tool | What it returns |
|---|---|
| `account_whoami` | The Snipd account the connection is signed in as. |
| `snips_list` | Your snips, newest first, grouped by episode with episode and show metadata. Each snip carries its markdown `content` (your note, else the snip's title and summary), its position in the episode, when you saved it, whether it is a favorite and the tags it is filed under. Paged with `limit`/`offset`. |
| `snips_read_full` | Your snips with their transcript: what is actually said in each one, as speaker turns. Up to 20 at a time, and only for episodes Snipd has processed and your plan lets you read. |
| `snips_delete` | Deletes snips you point at. They disappear from the app on every device. The agent asks first. |
| `snips_tag`, `snips_untag` | Files snips under tags, creating the tags that do not exist yet, or takes tags off them. Tags are given by name. |
| `snips_create_tag`, `snips_remove_tag` | Creates an empty tag, or deletes one from your account: it comes off every snip that carried it, and the snips are kept. The agent asks before deleting one. |
| `subscriptions_list` | The podcasts you follow, all at once, the one with the newest episode first, each with when you subscribed and whether you get new-episode notifications. |
| `subscriptions_latest_episodes` | What is new in the podcasts you follow, newest first, leaving out episodes you finished or archived (like the app's Latest feed). Paged. |
| `subscriptions_search_moments` | Find moments across public podcasts you follow using embedding-based semantic search of episode transcripts. Filter by publication date or people. Requires Snipd Premium. |
| `listen_history_search_moments` | Find moments across public podcast episodes in your listen history using embedding-based semantic search of their transcripts. Filter by publication date, when you first listened, or people. Requires Snipd Premium. |
| `subscriptions_add`, `subscriptions_remove` | Follow a show by id or RSS feed URL (unknown feeds are imported first), or unfollow shows. The agent asks before calling them. |
| `shows_details`, `shows_episodes` | A show as its page in the app, and its episodes with the app's filters (sort, title search, play status, archived). |
| `episodes_details`, `episodes_transcript`, `episodes_ai_summaries` | An episode as its page in the app, its transcript as speaker turns (the whole thing, or a window of it), and the AI snips the app shows. Transcript and AI snips follow the app's AI-access rule: free-for-all episodes, Snipd Premium, or episodes you unlocked in the app. |
| `filters_list`, `filters_episodes` | Your episode feeds (the app's tabs, standard and custom) and the episodes in one of them. |
| `history_list` | What you listened to, most recent first, with your progress. |
| `queue_list`, `queue_add`, `queue_play_now`, `queue_remove` | Your play queue: see it, queue episodes next or last, make one the head of the queue, remove episodes. Your devices pick the changes up within seconds. |
| `uploads_initiate` | Snipd Premium only. Reserves upload space and returns a signed URL the agent PUTs a local audio/video file to; the file becomes an episode once Snipd has processed it. |
| `uploads_list` | Pending uploads (uploading, processing, error) and processed ones grouped by folder, plus the upload quota. |
| `uploads_delete` | Deletes a pending upload. |

## Filtering moment searches

Both search tools accept `query`, `limit` (default 10, maximum 20), and optional
`publish_date_min`, `publish_date_max` and `person_ids`. Dates use `YYYY-MM-DD`
and include the supplied day, in UTC. A person filter matches episodes featuring
any listed person as a guest or host. Results include guest names and person IDs
so you can narrow a follow-up search to a guest.

`listen_history_search_moments` also accepts `first_listen_date_min` and
`first_listen_date_max` to filter by when you first listened to an episode.
All supplied filters apply together.

## Repository layout

| Path | Used by |
|---|---|
| `.mcp.json` | The MCP server both plugins install (Claude Code and Codex read the same `mcpServers` shape) |
| `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` | Claude Code plugin and its marketplace |
| `.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json` | Codex plugin and its marketplace |
| `skills/snipd/SKILL.md` | Using Snipd: the tools and how to work with snips (reading, deleting, tagging), subscriptions and episodes. Shared by every agent |
| `skills/snipd-connect/SKILL.md` | Adding the server to a client and completing the sign-in. Shared by every agent |
| `skills/upload-file/SKILL.md` | Uploading a local audio/video file: options, `uploads_initiate`, the PUT, what to tell the user |
| `skills/upload-youtube-video/SKILL.md` | Same for a YouTube video: yt-dlp (with consent) for metadata (title, channel, description, thumbnail, language) and the audio-only download, upload with the video URL |
| `skills/upload-check-pending/SKILL.md` | Reporting pending uploads, explaining statuses, cleaning up stuck or failed ones |
| `skills/snipd-update/SKILL.md` | Updating the installed plugin, and turning on Claude Code auto-update. Shared by every agent |
| `skills/*/agents/openai.yaml` | Codex-only sidecars that declare the MCP dependency so Codex offers to install it |

## Versions

Clients only pick up a new version of the plugin when `version` in `.claude-plugin/plugin.json` and
`.codex-plugin/plugin.json` changes — a new commit alone does nothing. So bump both in the same
commit as the change. The MCP server has its own version, reported as `serverInfo.version` when the
agent connects; being remote, it is always current for users.

How a new version reaches a user:

- **Claude Code** can update in the background, but auto-update is **off by default** for
  third-party marketplaces like this one. A user turns it on at `/plugin` → **Marketplaces** →
  the Snipd marketplace → **Enable auto-update**, which persists `"autoUpdate": true` on that
  marketplace's entry in `~/.claude/plugins/known_marketplaces.json`. Once on, Claude Code checks
  within ~10 minutes of session start, updates the plugin on disk, and prompts for
  `/reload-plugins` (or loads it at the next launch). Manually:
  `claude plugin marketplace update <key>` then `claude plugin update snipd@<key>`. Note `<key>`
  is whatever name the marketplace was added under — `snipd-app` for fresh installs, but `snipd`
  for ones added before the rename.
- **Codex** has no auto-update for user-added marketplaces; only OpenAI's curated repo syncs on
  its own. Users must run `codex plugin marketplace upgrade snipd-app`, which refreshes Git
  marketplaces only (a locally added one always reads its directory). The installed plugin is then
  re-read only if the `version` changed.

The `snipd-update` skill carries all of this for the agent, and `snipd-connect` offers auto-update
once at the end of setup rather than leaving the user to discover it.

| Plugin | Server | What changed |
|---|---|---|
| 0.9.0 | 0.7.0 | Filter moment searches by publication date, first-listened date and people; results include guest person IDs. |
| 0.8.0 | 0.7.0 | Search moments in your subscriptions and listen history, with transcript passages and episode links (Snipd Premium). |
| 0.7.0 | 0.6.0 | `snipd-update` skill: update the plugin from either agent, and offer Claude Code auto-update. `snipd-connect` now raises it once after a successful sign-in. |
| 0.6.0 | 0.6.0 | Snips can be changed, not only read: `snips_delete`, `snips_tag`, `snips_untag`, `snips_create_tag`, `snips_remove_tag`, and `snips_read_full` for the words of a snip. `episodes_transcript` no longer caps a read: with no bounds it returns the whole transcript, `start_seconds` alone reads to the end of the episode, and two bounds read exactly that stretch. |
| 0.5.0 | 0.5.0 | Subscriptions (add, remove), shows (details, filtered episodes), episodes (details, transcript, AI snips), feeds, listen history, play queue with the `queue` skill; one `Show` and one `Episode` model everywhere (`snips_list` episodes now say `published_at`). |
| 0.2.x | 0.2.x | Uploads of local audio files and YouTube videos (Snipd Premium), with the three `upload-*` skills. |
| 0.1.0 | 0.1.0 | Snips and the account, with the `snipd` and `snipd-connect` skills. |

Keep at least two skills in the plugin. Codex gives a plugin its own skill root only when the
plugin ships two or more skills (`shared_host_alias_roots` in `codex-rs/ext/skills/src/host_aliases.rs`);
with a single skill the model must expand `<marketplace>/<plugin>/<version>/skills/<skill>/SKILL.md`
itself and reliably drops a segment, so every session starts with a failed read.

Validate the Claude Code plugin locally with `claude plugin validate . --strict` and try it with
`claude --plugin-dir .`. Inside a checkout, Codex discovers the marketplace automatically; elsewhere
`codex plugin marketplace add /path/to/snipd-mcp` then `codex plugin add snipd@snipd-app`.
