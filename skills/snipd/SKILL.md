---
name: snipd
description: Use when the user mentions Snipd, their podcast snips, highlights, notes or tags (deleting, tagging and untagging them included), the podcasts they follow or subscribe to, what is new in their podcasts, a show or an episode (details, transcript, AI snips), their episode feeds or filters, or what they listened to.
compatibility: Needs the Snipd MCP server (remote, signs in with the user's Snipd account). Mostly reads the user's data; deletes or tags snips and changes subscriptions only through the tools named for it, after confirmation. The play queue has its own skill.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Snipd

Snipd is a podcast app. A "snip" is a moment the user saved from an episode, with an AI title
and summary and often the user's own note. The Snipd MCP server exposes the signed-in user's
snips (which it can also delete and file under tags), the podcasts they follow, shows and
episodes (with transcripts and AI snips where the user has access), their episode feeds, their
listen history and their play queue, and, for Snipd Premium users, lets them upload their own audio.

If the `snipd` tools (`account_whoami`, `snips_list`, `subscriptions_list`, ...) are not available, follow the
`snipd-connect` skill first: it adds the server to this agent and walks the user through
signing in.

Every id is a UUID that came from an earlier result. Never guess or make up an id; resolve
titles first through the listing tools.

## Tools

| Tool | What it returns |
|---|---|
| `account_whoami` | The signed-in Snipd account (user id, email, username, public name). Call it when the user asks which account is connected. |
| `snips_list(limit, offset)` | Snips newest first, grouped by episode with the episode and its show. `limit` is at most 500. `content` is markdown: the user's note, else the snip's title and summary. `start_seconds`/`end_seconds` locate the snip in the episode. `tags` are the names the snip is filed under. Page with `next_offset` until it is `null`. |
| `snips_read_full(snip_ids)` | The same snips plus their `transcript`: what is actually said in each one, as speaker turns with names and roles. At most 20 at a time. Read these before quoting a snip — `content` is the user's note or Snipd's summary, not the words. A snip whose episode Snipd has not processed, or that this account may not read, comes back with no `transcript` and an `ai_access` saying why. |
| `snips_delete(snip_ids)` | Deletes snips, up to 100 at a time. They disappear from the app on every device. Ids that are not (or no longer) the user's come back in `not_found` instead of failing. Ask first. |
| `snips_tag(snip_ids, tags)` | Files snips under tags, creating the tags that do not exist yet. Give a tag by name, as the user says it, or by id. Snips already carrying it keep it. Returns the tags used, which are new, and how many memberships were added. |
| `snips_untag(snip_ids, tags)` | Takes those tags off those snips. The tags stay on the account and on other snips. Names the user has no tag for come back in `unknown_tags`. |
| `snips_create_tag(title)` | Creates an empty tag. A tag the user already has under that name is returned instead (`already_existed`), so it is safe to call. |
| `snips_remove_tag(tag)` | Deletes a tag from the account: it comes off every snip that carried it, and the snips themselves are kept. Ask first. |
| `subscriptions_list()` | Every podcast the user follows, all at once, the show with the newest episode first. Each entry has the `show` (`id`, `title`, `author`, `image_url`, `website`, `rss_feed_url`, `language`, `categories`, `latest_episode_at`), `subscribed_at` and `notifications_enabled`. |
| `subscriptions_latest_episodes(limit, offset)` | The newest episodes across the podcasts the user follows, newest first, like the app's Latest feed: episodes the user already finished or archived are left out. `limit` is at most 200. Page with `next_offset`. |
| `subscriptions_search_moments(query, limit=10)` | Find moments across public podcasts you follow using embedding-based semantic search of episode transcripts. Requires Snipd Premium. |
| `listen_history_search_moments(query, limit=10)` | Find moments across public podcast episodes in your listen history using embedding-based semantic search of their transcripts. Requires Snipd Premium. |
| `subscriptions_add(show_id \| rss_feed_url, notifications_enabled)` | Subscribes the user to a show, by id or by RSS feed URL (unknown feeds are imported first, which takes a few seconds). Reports `already_subscribed` and, for RSS, `imported`. Ask first. |
| `subscriptions_remove(show_ids)` | Unsubscribes from the given shows; ids the user did not follow come back as `not_subscribed`. Nothing else is deleted. Ask first. |
| `shows_details(show_id)` | The show as its page in the app: the compact fields plus description, owner, subcategories, funding link, counts of live episodes, snips (all users) and subscribers, and the user's `is_subscribed` / `notifications_enabled`. |
| `shows_episodes(show_id, sort, search, play_status, include_archived, limit, offset)` | The episodes of one show with the app's show-page filters: `sort` newest (default), oldest, longest, shortest or most_snipped; `search` words that must all appear in the title; `play_status` all, not_started, started, not_completed or completed; archived episodes hidden unless `include_archived`. Public shows and the user's own private feeds / upload folders only. |
| `episodes_details(episode_id)` | The episode as its page in the app: description, language, hosts and guests, chapters and AI takeaways (only with AI access), counts, `has_transcript`, `ai_access` (status and reason), `is_archived`, `is_favorite`, `is_queued` and the user's `listen_state`. |
| `episodes_transcript(episode_id, start_seconds, end_seconds)` | The transcript as speaker turns (`speaker`, `role`, `start_seconds`, `end_seconds`, `text`). Both bounds are optional and honoured exactly: no bounds returns the WHOLE transcript (roughly ten thousand words per hour of audio), `start_seconds` alone reads from there to the end, both read that stretch. `has_more`/`next_start_seconds` appear only when an `end_seconds` stopped short. Needs AI access. |
| `episodes_ai_summaries(episode_id)` | The AI snips the app shows on the episode: type, markdown `body_md`, the quote and its speaker, position in seconds. Needs AI access. |
| `filters_list()` | The user's episode feeds in the app's tab order: standard feeds (`latest`, `favorite`, `in_progress`, `history`, `most_snipped`, `guest_following`; `downloaded` only exists on the device) and custom filters with their definition. |
| `filters_episodes(filter_id, limit, offset)` | The episodes of one feed, as the app fills that tab. |
| `history_list(in_progress_only, limit, offset)` | What the user listened to, most recent first, with position, `progress` (0-1) and `completed`. |
| `queue_list`, `queue_add`, `queue_play_now`, `queue_remove` | The play queue: see the `queue` skill. |
| `uploads_initiate(...)` | Snipd Premium only. Starts an upload of a local audio/video file and returns the signed URL to PUT the bytes to; takes title, author, description, thumbnail (cover) and language metadata. Use it through the `upload-file` and `upload-youtube-video` skills. |
| `uploads_list(status)` | The user's uploads: `pending` (uploading, processing, error) and `completed` (processed files grouped by folder, each with its episode), plus the upload quota. |
| `uploads_delete(upload_id)` | Deletes a pending upload. Processed uploads are removed in the app. |

Episodes everywhere carry `id`, `title`, `published_at`, `duration_seconds`, `image_url`, `website`,
`ai_description` (Snipd's short AI description; `null` until generated) and their `show`.

## AI access

Transcripts, chapters, AI snips and takeaways are AI content. `episodes_details` says whether the user
may read them in `ai_access.status`: `available`, `locked` (the free plan unlocks two processed episodes
a week by opening them in the Snipd app; Snipd Premium includes every processed episode) or `not_processed`
(Snipd has no transcript yet). Nothing is unlocked, processed or charged from here: when a tool answers
that the content is locked, explain how to unlock it in the app and offer the parts that are open
(`ai_description`, hosts and guests, the user's own snips).

## Working with subscriptions and shows

- "Which podcasts do I follow?": `subscriptions_list` returns everything at once, so never page it.
  Sort or filter as asked; `latest_episode_at` says how active a show is and `categories` what it
  is about.
- "What's new in my podcasts?": `subscriptions_latest_episodes`. Mention that episodes the user
  already finished or archived are not in it. One page is usually enough.
- "Tell me about show X" / "list the episodes of X": find the show first. Match the title in
  `subscriptions_list`, or take `show.id` from an episode or snip; then `shows_details` or
  `shows_episodes`. Use `search` for a title the user remembers and `play_status` for "unplayed" or
  "finished" questions. When the tool answers that the show was not found, the id is wrong or the
  show is private: say so and offer to look it up in the user's subscriptions.
- Subscribing and unsubscribing change the user's account: state which show(s) and wait for a clear yes
  before calling `subscriptions_add` or `subscriptions_remove`. For an RSS URL, say that unknown feeds
  are imported first and can take a few seconds. Afterwards, tell the user the app shows the change on
  its next start or pull-to-refresh.

## Working with episodes

- Start with `episodes_details`: it has the description, who is on it, the user's progress and the AI
  access status, so you know whether the transcript and AI snips can be read.
- "What is this episode about?" / "key points": `episodes_ai_summaries` when available, else
  `ai_description` and the description from the details.
- Quotes, exact wording, "what did they say about X": `episodes_transcript`. Bound the read when you know
  where to look: `start_seconds` near a chapter's start from the details, or where the user is, and an
  `end_seconds` when you only want that stretch. Nothing is capped, so a bounded read returns everything
  between the two, and `start_seconds` on its own runs to the end of the episode.
- Call it with no bounds at all when you need the whole thing: the user asked for the full transcript, or
  the question ("does she ever mention X?", "summarise the whole conversation") cannot be answered from
  one part of the episode. Expect roughly ten thousand words per hour of audio, so for a long episode say
  what you are about to read, and prefer a bounded read when the chapters or a snip point at the minute.
- Show positions as `h:mm:ss` or `mm:ss`, dates as dates, durations as `h:mm`.

## Feeds and history

- "My feeds" / "my filters": `filters_list`, then `filters_episodes` with the feed's `id`. `downloaded`
  cannot be listed from here; say so.
- "What have I listened to?" / "where was I?": `history_list`; `in_progress_only` for unfinished
  episodes. `progress` is a fraction of the episode.

## Working with snips

- Quote a snip with its episode and show, and show positions as `mm:ss`. When the user wants the actual
  words (a quote, "what did they say", a verbatim passage), call `snips_read_full` for those snips:
  `snips_list` only carries the note and Snipd's summary. Attribute a quote to the speaker the
  transcript names, and say when a snip's transcript is not available instead of paraphrasing it.
- "Recent" means `create_ts`; favorites are `is_favorite`; the names a snip is filed under are `tags`.
- Pages are cut by snip, so one episode can continue on the next page: fetch all pages before
  counting or summarising "everything".
- Reading snips never changes the user's account. Uploads do add episodes: follow the `upload-file`,
  `upload-youtube-video` and `upload-check-pending` skills for those.

### Deleting and tagging

- Snip ids come from `snips_list`. Resolve what the user described to actual snips first, and name the
  ones you are about to change ("the three snips from *How to focus*") rather than counting them.
- `snips_delete` removes snips from the app everywhere. Confirm first, always, and never delete more
  than the user asked for: when a request is broad ("delete my old snips"), list what matches and let
  them approve it.
- Tags are the names the app shows on a snip. `snips_tag` creates the ones that do not exist, so tag
  in one call rather than creating a tag first; use the name the user used, and reuse an existing tag
  when it is the same name in different case or spacing (the tools already match that way).
- `snips_untag` takes a tag off some snips; `snips_remove_tag` deletes the tag itself, everywhere.
  They are easy to confuse: say which one you are about to do, and confirm the second.
- Changes show up in the app the next time it syncs, not instantly.

## Finding moments in podcasts

Use `subscriptions_search_moments` for a topic across followed public podcasts and
`listen_history_search_moments` for something discussed in episodes the user listened to.
These tools require Snipd Premium and use embedding-based semantic search over transcripts: describe the topic,
idea or moment to find.

Request 1–20 chunks (default 10). Expect roughly 18,000 tokens for 10 chunks.
Results include transcript passages with speakers, timestamps, episode titles, IDs and
links. Overlapping passages are combined.
Cite the returned episode links when using these passages.
