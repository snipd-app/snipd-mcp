# Snipd for Claude Code, Codex and other agents

Connect your coding agent to your [Snipd](https://www.snipd.com) account and let it work with your
podcasts: read, delete and tag your snips and notes, browse and manage the shows you follow, search for
moments in your subscriptions and listen history, find people by name or bio, open episodes (details,
transcripts and AI snips), see your feeds and listen history, control your play queue, and upload your
own audio. This repository is the official install kit for the Snipd MCP server: a Claude Code
plugin, a Codex plugin and eight [Agent Skills](https://agentskills.io) that teach the agent what the
tools do and how to use them.

The server is remote (nothing runs on your machine). Browsing never changes your account. Actions
that do include deleting or tagging snips, subscribing or unsubscribing, changing the play queue
(your devices pick it up within seconds), and adding episodes through uploads or text-to-speech.
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

## Services the skills contact

Besides the Snipd MCP server, two skills send data elsewhere, always from the user's own machine:

- `upload-file` uploads the chosen file to the Google Cloud Storage URL that `uploads_initiate` returns (Snipd's storage).
- `upload-youtube-video` runs [yt-dlp](https://github.com/yt-dlp/yt-dlp) to read the video's details and download its audio
  from YouTube, then uploads it to Snipd's storage the same way.

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
| `subscriptions_search_moments` | Find moments across public podcasts you follow using embedding-based semantic search of episode transcripts. Filter by publication date, people, language or snip count. Requires Snipd Premium. |
| `listen_history_search_moments` | Find moments across public podcast episodes in your listen history using embedding-based semantic search of their transcripts. Filter by publication date, when you first listened, people, language or snip count. Requires Snipd Premium. |
| `subscriptions_add`, `subscriptions_remove` | Follow a show by id or RSS feed URL (unknown feeds are imported first), or unfollow shows. The agent asks before calling them. |
| `people_search` | Find people on public podcasts by name (keyword search) or bio (embedding-based semantic search). Returns up to 20 matches with name, bio, person ID and snip count. |
| `shows_details`, `shows_episodes` | A show as its page in the app, and its episodes with the app's filters (sort, title search, play status, archived). |
| `episodes_details`, `episodes_transcript`, `episodes_ai_summaries` | An episode as its page in the app, its transcript as speaker turns (the whole thing, or a window of it), and the AI snips the app shows. AI snips follow the app's AI-access rule: free-for-all episodes, Snipd Premium, or episodes you unlocked in the app. The full transcript follows the app's export rule: Snipd Premium, for episodes you had processed, exported before or listened to enough of. |
| `filters_list`, `filters_episodes` | Your episode feeds (the app's tabs, standard and custom) and the episodes in one of them. |
| `history_list` | What you listened to, most recent first, with your progress. |
| `queue_list`, `queue_add`, `queue_set_current`, `queue_remove` | Your play queue: see it, queue episodes next or last, make one the head of the queue, remove episodes. Your devices pick the changes up within seconds. |
| `uploads_initiate` | Snipd Premium only. Reserves upload space and returns a signed URL the agent PUTs a local audio/video file to; the file becomes an episode once Snipd has processed it. |
| `uploads_list` | Pending uploads (uploading, processing, error) and processed ones grouped by folder, plus the upload quota. |
| `uploads_delete` | Deletes a pending upload. |
| `uploads_text_to_speech` | Snipd Premium only. Reads text you supply aloud (text-to-speech) and saves the recording as a private episode in your Uploads, with optional speech editing for written articles and a cover image. Estimates the AI credits first; generates only when you confirm. |
| `feedback_submit` | Sends your feedback about Snipd's tools to the Snipd team, after you approve the message. Your agent offers it when you ask for something Snipd cannot do yet or a tool misbehaves. |

## Filtering moment searches

Only episodes Snipd has AI-processed (including transcription) are searchable.

Both search tools accept `query`, `limit` (default 10, maximum 20), and these optional filters:

- `publish_date_min`, `publish_date_max`: dates use `YYYY-MM-DD` and include the
  supplied day, in UTC.
- `person_ids`: matches episodes featuring any listed person as a guest or host.
  Results include guest names and person IDs so you can narrow a follow-up search
  to a guest.
- `languages`: matches episodes in any of these languages, given as two-letter
  codes such as `"en"` or `"de"`.
- `min_snips`: only episodes with at least this many snips, a popularity signal.
  Accepts **0, 5, 50, 100, 250, 500, 1000 or 2500**; 0 applies no filter.
- `min_show_snips`: only shows with at least this many snips in total.
  Accepts **0, 5, 50, 100, 500, 1000, 5000, 10000 or 50000**; 0 applies no filter.

`listen_history_search_moments` also accepts `first_listen_date_min` and
`first_listen_date_max` to filter by when you first listened to an episode.
All supplied filters apply together.

## Finding people

Use `people_search(query, search_by, min_snips=0)` with `search_by="name"` when you
know a name, or `search_by="bio"` to find people by
background or expertise, such as "robotics founder". Name search is
case-insensitive keyword search with fuzzy matching; bio search is embedding-based
semantic search. Available to every signed-in Snipd user.

`min_snips` accepts only **0, 5, 50, 100, 250, 500, 1000, 2500 or 5000**;
0 applies no snip-count filter. Results include the numeric snip count and a
`person_id` you can pass to the moment-search tools' `person_ids` filter.
