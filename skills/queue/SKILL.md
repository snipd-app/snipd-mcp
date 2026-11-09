---
name: queue
description: >-
  Use when the user wants to see or change their Snipd play queue: what is queued or playing, queue an episode, play something next or now, remove episodes from the queue.
compatibility: Needs the Snipd MCP server (remote, signs in with the user's Snipd account). Changes the user's play queue.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Snipd play queue

The Snipd app keeps one play queue per user, shared by all their devices. The first item is the one
the player is on; the rest play in order. These tools read and change that queue the way the app
does.

If the `snipd` tools are not available, follow the `snipd-connect` skill first.

## Tools

| Tool | What it does |
|---|---|
| `queue_list(limit, offset, include_ai_episode_details)` | The queue in play order, paged (50 by default). Each item is the episode with its `queue_position` (0 is the episode the player is on), `playback_position_seconds` (where playback resumes) and `added_ts`; `queue_length` is the whole queue. Turn `include_ai_episode_details` off when you only need the titles: the details cost 0.05 AI credits per episode. |
| `queue_add(episode_ids, position)` | Adds episodes, in the given order. `top` (default) puts them right after the playing item, so they play next; `bottom` appends them. An episode already in the queue is moved, not duplicated. Each resumes where the user left it (from the start when finished). Returns `added_episode_ids`, `moved_episode_ids` and the `queue_length`. |
| `queue_set_current(episode_id)` | Makes the episode the head of the queue, moving it there if it is queued. The app switches to it; playback itself is not started from here, so the user may need to press play. Returns the `queue_length`. |
| `queue_remove(episode_ids)` | Takes episodes out of the queue. Ids that were not queued come back in `not_queued_episode_ids`. |

## How to work

1. Resolve the episodes first. Ids come from any tool that lists episodes, e.g. `followed_shows_latest_episodes`,
   `shows_episodes`, `listen_history_list`, `queue_list` or `snips_list` (the `snipd` skill). Never guess
   an id; when the user names an episode, find it and confirm the title before queueing.
2. When the outcome depends on what is already in the queue (e.g. "move X after Y", "clear everything but the current one")
   then read the queue with `queue_list` before changing it.
3. Adding is safe to repeat; removing is not: for `queue_remove`, name the episodes and wait for a
   clear yes. Removing the playing item makes the next one the head.
4. Tell the user what changed (read the queue again with `queue_list` when they want to see it). For
   `queue_set_current`, say that the app jumps to the episode but they will have to press play inside the Snipd app to
   start listening.
5. Show `playback_position_seconds` as `mm:ss` and say "resumes at" when it is not zero.

## Limits

- The backend cannot reorder arbitrary items in one call: express a reorder as `queue_add` calls
  (`top` or `bottom`) and say so if the user asks for something finer.
- Episodes must exist and be visible to the user (public shows, or their own private feeds and
  upload folders); otherwise the whole call fails and nothing changes.
