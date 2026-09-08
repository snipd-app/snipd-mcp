---
name: queue
description: Use when the user wants to see or change their Snipd play queue: what is queued or playing, queue an episode, play something next or now, remove episodes from the queue.
compatibility: Needs the Snipd MCP server (remote, signs in with the user's Snipd account). Changes the user's play queue; the user's devices pick the change up within seconds.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Snipd play queue

The Snipd app keeps one play queue per user, shared by all their devices. The first item is the one
the player is on; the rest play in order. These tools read and change that queue the way the app
does, and the app's devices refetch it as soon as a change lands.

If the `snipd` tools are not available, follow the `snipd-connect` skill first.

## Tools

| Tool | What it does |
|---|---|
| `queue_list()` | The queue in play order. Each item has its `episode`, `position_seconds` (where playback resumes), `added_at` and `is_playing` (the first item). |
| `queue_add(episode_ids, position)` | Adds episodes, in the given order. `top` (default) puts them right after the playing item, so they play next; `bottom` appends them. An episode already in the queue is moved, not duplicated. Each resumes where the user left it (from the start when finished). Returns the resulting queue. |
| `queue_play_now(episode_id)` | Makes the episode the head of the queue, moving it there if it is queued. The app switches to it when it picks up the change; playback itself is not started from here, so the user may need to press play. Returns the resulting queue. |
| `queue_remove(episode_ids)` | Takes episodes out of the queue. Ids that were not queued come back as `not_queued`. |

## How to work

1. Resolve the episodes first. Ids come from `shows_episodes`, `subscriptions_latest_episodes`,
   `filters_episodes`, `history_list`, `queue_list` or `snips_list` (the `snipd` skill). Never guess
   an id; when the user names an episode, find it and confirm the title before queueing.
2. Read the queue with `queue_list` before changing it when the outcome depends on what is there
   ("move X after Y", "clear everything but the current one").
3. Adding is safe to repeat; removing is not: for `queue_remove`, name the episodes and wait for a
   clear yes. Removing the playing item makes the next one the head.
4. Tell the user what the queue looks like afterwards, in play order, and that their devices update
   within seconds. For `queue_play_now`, say that the app jumps to the episode but may wait for them
   to press play.
5. Show `position_seconds` as `mm:ss` and say "resumes at" when it is not zero.

## Limits

- The backend cannot reorder arbitrary items in one call: express a reorder as `queue_add` calls
  (`top` or `bottom`) and say so if the user asks for something finer.
- Episodes must exist and be visible to the user (public shows, or their own private feeds and
  upload folders); otherwise the whole call fails and nothing changes.
