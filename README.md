# Snipd for Claude Code, Codex and other agents

**MCP server URL:** `https://mcp.snipd.com/mcp`

Connect your coding agent to your [Snipd](https://www.snipd.com) account and let it work with your
podcasts: read, delete and tag your snips, browse and manage the shows and guests you follow,
search what was said in podcasts, find people by name or bio, open episodes (AI details, AI summaries and
transcripts), see your favorites, custom lists, listen history and what is trending, control your play queue,
and upload your own audio. This repository is the official install kit for the Snipd MCP server: a Claude Code
plugin, a Codex plugin and seven [Agent Skills](https://agentskills.io) that teach the agent what the
tools do and how to use them.

The server is remote (nothing runs on your machine). Browsing never changes your library, though some
tools spend AI credits (see below). Actions that do change it include deleting or tagging snips, following or
unfollowing shows and guests, favorites, changing the play queue, and
adding episodes through uploads.
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

1. Open [**Settings → Connectors**](https://claude.ai/settings/connectors).
2. Click **Add custom connector**.
3. Name it **Snipd**, enter `https://mcp.snipd.com/mcp` and click **Add**.
4. Click **Connect** and sign in with your Snipd account.

### ChatGPT

In ChatGPT on the web:

1. Open [**Plugins**](https://chatgpt.com/plugins) in the sidebar.
2. Click **Add** in the top right, then **Add custom MCP server**.
3. Name it **Snipd**.
4. Under **Connection**, keep **Server URL** and enter `https://mcp.snipd.com/mcp`.
5. Keep **OAuth**, tick **I understand and want to continue** and click **Create as a plugin**.
6. Install the plugin and sign in with your Snipd account.
7. In a chat, type `@` and pick **Snipd**.

## Services the skills contact

Besides the Snipd MCP server, two skills send data elsewhere, always from the user's own machine:

- `upload-file` uploads the chosen file to the Google Cloud Storage URL that `uploads_initiate` returns (Snipd's storage).
- `upload-youtube-video` runs [yt-dlp](https://github.com/yt-dlp/yt-dlp) to read the video's details and download its audio
  from YouTube, then uploads it to Snipd's storage the same way.

## What the agent can do

Some tools cost AI credits, the unit Snipd uses for its AI features: free accounts get 20 per calendar month, Snipd
Premium includes many more each calendar month (upgrade in the Snipd mobile app, on the "You" screen). Every response
says what the call cost and what is left; `account_info` shows the balance.

| Tool | What it returns | AI credits |
|---|---|---|
| `account_info` | The Snipd account the connection is signed in as, its plan and its AI credits. | free |
| `snips_list` | Your snips, newest first, grouped by episode, each with its AI-generated note, its position in the episode, when you saved it, whether it is a favorite or an auto snip, and its tags. Filters: date, episode, show, favorite, auto snip, tag. | free |
| `snips_details` | Your snips with their episode and what is said in them, cut after 7 minutes. | free |
| `snips_delete`, `snips_tag`, `snips_untag` | Delete snips, file them under tags (missing tags are created) or take tags off them. The agent asks before deleting. | free |
| `tags_list`, `tags_create`, `tags_delete` | Your tags with their snip counts; create one; delete one everywhere (the snips stay). | free |
| `followed_shows_list`, `followed_shows_latest_episodes` | The shows you follow, and their episodes with the filters of the app's custom lists (play status, AI-processed only, sorting incl. most snipped). | free |
| `show_follow`, `show_unfollow` | Follow a show by id or RSS feed URL (unknown feeds are imported first), or unfollow one. The agent asks first. | free |
| `shows_details`, `shows_episodes` | Shows as their page in the app, and a show's episodes with the app's filters. | free |
| `episodes_details` | Everything about episodes: the AI description, hosts and guests, chapters, mentioned books, snip count and your progress. | 0.05 per episode |
| `episodes_ai_summaries` | The AI snips of episodes: the key moments and takeaways. | 1 per episode, free for episodes you had processed |
| `episodes_transcripts` | Snipd Premium only. The transcript of an episode, whole or a part. | once per episode: 1 per minute, 0.5 if you listened to it, free if you processed or exported it before |
| `favorite_episodes_list`, `favorite_episodes_add`, `favorite_episodes_remove` | Your favorite episodes. | free |
| `followed_guests_list`, `guests_follow`, `guests_unfollow`, `followed_guests_latest_episodes` | The guests you follow and the newest episodes they appear in. | free |
| `listen_history_list` | What you listened to, most recent first, with your progress. | free |
| `custom_episode_filters_list`, `custom_episode_filters_episodes` | The custom lists you created in the app, and their episodes. | free |
| `discover_episodes` | The Discover lists: trending, most snipped in the last 30 days, most snipped of all time. | free |
| `transcripts_search` | Find where something was said in the shows you follow, your listen history or all public shows. | 1 per search |
| `people_search` | Find people on public podcasts by name or by bio. | free |
| `queue_list`, `queue_add`, `queue_set_current`, `queue_remove` | Your play queue: see it, queue episodes next or last, make one the head of the queue, remove episodes. | free |
| `uploads_initiate`, `uploads_list`, `uploads_delete` | Snipd Premium only. Upload a local audio/video file (it becomes an episode once processed), list your uploads and quota, delete a pending one. | AI processing 1 per minute |
| `feedback_submit` | Sends your feedback about Snipd's tools to the Snipd team, after you approve the message. | free |

Every episode list adds the AI description, guests and snip count of each episode by default, for 0.05 AI credits per
episode; the agent turns this off when it only needs titles.

## Searching transcripts

Only episodes Snipd has AI-processed are searchable, in public shows (private feeds and uploads are not included).
`transcripts_search` accepts `query`, `scope` (`followed_shows`, `listen_history` or `all`), `limit` (default 10,
maximum 20) and these optional filters. A common use is `scope="listen_history"`, to find something you heard on a
podcast.

- `show_ids`: only these shows.
- `publish_date_min`, `publish_date_max`: dates use `YYYY-MM-DD` and include the supplied day, in UTC.
- `first_listen_date_min`, `first_listen_date_max` (with `scope="listen_history"`): when you first listened.
- `person_ids`: episodes featuring any listed person as a guest or host.
- `languages`: episodes in any of these languages, given as two-letter codes such as `"en"` or `"de"`.
- `min_snips`: only episodes with at least this many snips, a popularity signal.
  Accepts **0, 5, 50, 100, 250, 500, 1000 or 2500**; 0 applies no filter.
- `min_show_snips`: only shows with at least this many snips in total.
  Accepts **0, 5, 50, 100, 500, 1000, 5000, 10000 or 50000**; 0 applies no filter.

All supplied filters apply together.

## Finding people

Use `people_search(query, search_by, min_snips=0)` with `search_by="name"` when you
know a name, or `search_by="bio"` to find people by
background or expertise, such as "robotics founder". Name search is
case-insensitive keyword search with fuzzy matching; bio search is embedding-based
semantic search. Available to every signed-in Snipd user.

`min_snips` accepts only **0, 5, 50, 100, 250, 500, 1000, 2500 or 5000**;
0 applies no snip-count filter. Results include the numeric snip count and a
`person_id` you can pass to `transcripts_search`'s `person_ids` filter or to `guests_follow`.
