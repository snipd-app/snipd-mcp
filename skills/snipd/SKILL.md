---
name: snipd
description: Use when the user mentions Snipd, their podcast snips, highlights, notes or tags (deleting, tagging and untagging them included), the shows they follow, what is new in their podcasts, a show or an episode (details, AI summary, transcript), their favorites, the guests they follow, their custom episode lists, what is trending on Snipd, what they listened to, searching what was said in podcasts, finding podcast guests and hosts, their AI credits, or giving feedback about Snipd's tools.
compatibility: Needs the Snipd MCP server (remote, signs in with the user's Snipd account). Mostly reads the user's data; deletes or tags snips and changes follows and favorites only through the tools named for it, after confirmation. Some tools cost AI credits. The play queue has its own skill.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Snipd

Snipd is a podcast app. A "snip" is a moment the user saved from an episode, with its note. The Snipd MCP server
exposes the signed-in user's snips and tags, the shows and guests they follow, shows and episodes (with AI
episode details, AI summaries and transcripts), their favorites, custom lists and listen history, the Discover
lists, a search through podcast transcripts for what was said (`transcripts_search`), people search, their play queue
and, for Snipd Premium, uploads. The server's own
instructions explain the terms (show, episode, snip, `snip_count`, AI credits) and the common use cases.

If the `snipd` tools (`account_info`, `snips_list`, `followed_shows_list`, ...) are not available, follow the
`snipd-connect` skill first: it adds the server to this agent and walks the user through signing in.

Every id (`show_id`, `episode_id`, `snip_id`, `person_id`, `tag_id`, `episode_filter_id`) came from an earlier
result. Never guess or make up an id; resolve titles first through the listing tools.

## Responses and AI credits

Every response is `{"data": …, "meta": …}`. On tools that can cost AI credits, `meta.cost` says what the call cost
(`ai_credits_charged`), what for (`breakdown`) and what is left (`ai_credits_remaining`); `account_info` shows the
balance. What costs AI credits:

| What | Price |
|---|---|
| AI episode details (AI description, guests, snip count) on episode lists, with `include_ai_episode_details` (on by default) | 0.05 per returned episode, every call |
| `episodes_details` (always with all AI episode details: hosts, guests, chapters, mentioned books) | 0.05 per episode |
| `episodes_ai_summaries` | 1 per episode; free for episodes the user had Snipd process |
| `transcripts_search` | 1 per call |
| `episodes_transcripts` (Premium) | once per episode: 1 per minute, 0.5 if the user listened to it, free if they processed or exported it before |

Everything else is free. Free accounts get 20 AI credits per calendar month; Premium includes many more each calendar
month. Users upgrade to Snipd Premium inside the Snipd mobile app, on the "You" screen. Turn
`include_ai_episode_details` off when you only need ids or titles (to queue, favorite or look up an episode you
already know), and keep pages at a reasonable size (10–20 episodes). When a call is refused for lack of credits, the
error says what it would cost and how to get more: tell the user.

## Tools

| Tool | What it returns |
|---|---|
| `account_info` | The signed-in account: username, public name, email, plan, AI credits left, when a Free account's credits reset. |
| `snips_list(...)` | Snips newest first, grouped by episode. Filters: `created_after`, `created_before`, `episode_id`, `show_id`, `is_favorite`, `is_auto_snip`, `tag_id`. Each snip has `note` (markdown, as the app shows it; `null` when empty), `start_seconds`/`end_seconds`, `create_ts`, `is_favorite`, `is_auto_snip` and its tag titles. `limit` at most 50; page with `next_offset` until it is `null`. |
| `snips_details(snip_ids, include_transcript)` | Up to 20 snips with their episode and what is said in them, as speaker turns, cut after 7 minutes. Read these before quoting a snip. The transcript is `null` when the user cannot see the episode's AI content in the app. |
| `snips_delete`, `snips_tag`, `snips_untag` | Delete snips; file them under tags (missing tags are created); take tags off them. Ask first before deleting. |
| `tags_list`, `tags_create`, `tags_delete` | The user's tags with `tag_id` and snip count; create one; delete one everywhere (the snips stay). Ask first before deleting. |
| `followed_shows_list` | Every followed show, the one with the newest episode first. |
| `followed_shows_latest_episodes(...)` | Episodes of the followed shows, newest first by default. Filters as in the app's custom lists: `show_ids`, `play_status` (`not_started`, `in_progress`, `completed`), `ai_processed_only`, `sort` (`newest`, `oldest`, `most_snipped`). `oldest` covers at most 100 followed shows; pass `show_ids` for a user who follows more. |
| `show_follow`, `show_unfollow` | Follow a show by `show_id` or RSS feed URL (unknown feeds are imported first), unfollow one. Ask first. |
| `shows_details(show_ids)` | Up to 50 shows as their page in the app, with the user's relation to them. |
| `shows_episodes(show_id, ...)` | One show's episodes, followed or not: `sort`, `title_search_term`, `play_status`, `include_archived`, `ai_processed_only`. |
| `episodes_details(episode_ids, include_shownotes)` | Up to 50 episodes: everything the episode screen shows, the user's progress (`listen`), and all AI episode details. |
| `episodes_ai_summaries(episode_ids)` | A markdown summary per episode, for up to 10 episodes: the key moments and takeaways, each with its title, start and end time, a link and its text. |
| `episodes_transcripts(episode_id, start_seconds, end_seconds, cost_estimate_only)` | Premium. The transcript, whole or a part, as speaker turns. The first call unlocks the whole episode's transcript; `cost_estimate_only` gives the price without charging. |
| `favorite_episodes_list`, `favorite_episodes_add`, `favorite_episodes_remove` | The user's favorite episodes. |
| `followed_guests_list`, `guests_follow`, `guests_unfollow`, `followed_guests_latest_episodes` | The people the user follows as guests, and the newest episodes they appear in. |
| `listen_history_list(in_progress_only, ...)` | What the user listened to, most recent first, with `listen` (last played, position, time listened, completed). |
| `custom_episode_filters_list`, `custom_episode_filters_episodes` | The custom lists the user created in the app, and their episodes. |
| `discover_episodes(list)` | The Discover lists: `trending`, `most_snipped_30_days`, `most_snipped_all_time`. |
| `transcripts_search(query, scope, ...)` | Find where something was said: see *Searching transcripts*. |
| `people_search(query, search_by, min_snips)` | People on public shows by name or bio, with `person_id` and snip count. |
| `queue_list`, `queue_add`, `queue_set_current`, `queue_remove` | The play queue: see the `queue` skill. |
| `uploads_initiate`, `uploads_list`, `uploads_delete` | Premium uploads: use them through the `upload-file`, `upload-youtube-video` and `upload-check-pending` skills. |
| `feedback_submit(message)` | Sends the user's feedback about these tools to the Snipd team. See *Sending feedback*. |

Episodes in lists carry `episode_id`, `title`, `show_id`, `show_title`, `publish_ts`, `duration_seconds`,
`image_url`, `share_url` and, with `include_ai_episode_details`, `ai_episode_details`.

## Working with shows and episodes

- "What's new in my podcasts?": `followed_shows_latest_episodes`; add `play_status=["not_started", "in_progress"]`
  for what the user has not finished, `sort="most_snipped"` for the ones listeners snipped most. One page is
  usually enough.
- "Tell me about show X" / "the episodes of X": match the title in `followed_shows_list`, or take `show_id` from an
  episode or snip; then `shows_details` or `shows_episodes` (`title_search_term` for a title the user remembers).
- "What is this episode about?" / "key points": the AI description is in the list; `episodes_ai_summaries` gives
  the key moments and takeaways; `episodes_details` adds hosts, guests, chapters and mentioned books.
- Quotes and exact wording from an episode: `transcripts_search` finds the passage; `episodes_transcripts` reads
  the transcript (Premium; for a long or unlistened episode, check the price with `cost_estimate_only` first when
  the user may not expect it). Bound the read with `start_seconds`/`end_seconds` when a chapter or a snip points at
  the minute.
- Following and unfollowing shows and guests, and changing favorites, change the user's account: say what you are
  about to change and wait for a clear yes. The app shows the change on its next start or pull-to-refresh.
- Show positions as `h:mm:ss` or `mm:ss`, dates as dates, durations as `h:mm`.

## Working with snips

- Quote a snip with its episode and show, and show positions as `mm:ss`. For the actual words, call `snips_details`:
  `snips_list` only carries the note. Attribute a quote to the speaker the transcript names, and say when a snip's
  transcript is not available instead of paraphrasing it.
- Use the filters rather than reading everything: `tag_id` from `tags_list`, `show_id`, `episode_id`,
  `created_after`/`created_before`, `is_favorite`. Pages are cut by snip, so one episode can continue on the next
  page: fetch all pages before counting or summarising "everything".
- `snips_delete` removes snips from the app everywhere. Confirm first, always, and never delete more than the user
  asked for: when a request is broad ("delete my old snips"), list what matches and let them approve it.
- `snips_tag` creates the tags that do not exist, so tag in one call rather than creating a tag first; use the name
  the user used. `snips_untag` takes a tag off some snips; `tags_delete` deletes the tag itself, everywhere. Say which
  one you are about to do, and confirm the second.
- Changes show up in the app the next time it syncs, not instantly.

## Searching transcripts

`transcripts_search` finds where something was said, by meaning rather than exact words, in public shows (private
feeds and uploads are not included). `scope` is `followed_shows` (default), `listen_history` or `all`. A common use is
`scope="listen_history"` to find something the user heard on a podcast ("what did that guest say about sleep?"), with
`first_listen_date_min` / `first_listen_date_max` when they remember roughly when. Use every filter that fits the
request; the more filters, the better the results usually are:

- `show_ids`, `person_ids` (from `people_search` or an episode's guests), `languages` (two-letter codes);
- `publish_date_min` / `publish_date_max` and, with `scope="listen_history"`, `first_listen_date_min` /
  `first_listen_date_max` (`YYYY-MM-DD`, both bounds include the day, UTC);
- `min_snips` (0, 5, 50, 100, 250, 500, 1000 or 2500) for popular episodes, `min_show_snips` (0, 5, 50, 100, 500,
  1000, 5000, 10000 or 50000) for popular shows.

It returns up to 20 passages (default 10), best first, overlapping ones merged, at most 4 from any one episode, each
with its episode, show, `share_url`, speakers, start and end, and the text with timestamps. Cite the episode when you
use a passage. To read more of one episode, use `episodes_transcripts`.

## Finding people

Use `people_search` with `search_by="name"` when you know the person's name, `search_by="bio"` for a background or
expertise such as "robotics founder" or "medical doctor at Stanford". `min_snips` accepts 0, 5, 50, 100, 250, 500,
1000, 2500 or 5000. Use the `person_id`s with `transcripts_search` to find what those people said, or with
`guests_follow`.

## Sending feedback

Snipd reads the feedback sent with `feedback_submit` to decide what to build next. Offer to send it when:

- the user asks for something none of these tools can do ("add this to a playlist", "export my snips to Notion"):
  say plainly that Snipd cannot do it from here yet, then offer to pass the request on;
- a tool fails, returns something wrong, or behaves differently from what its description says;
- the user is frustrated with Snipd here, or suggests an improvement.

Offer once per topic, and do not interrupt a task that is going well. Write the message in the user's words: what
they wanted to do and what happened, with the tool name when one was involved. Leave out private details the feedback
does not need. Show the user the exact message and call `feedback_submit` only after they agree; afterwards, thank
them. For anything that needs an answer, point the user to the feedback chat in the Snipd app ("You" → settings →
"Feedback").
