---
name: upload-youtube-video
description: Use when the user wants to import a YouTube video into Snipd to listen to it and snip it. Reads the video's metadata and downloads its audio with yt-dlp on the user's machine, then uploads it like a file. Snipd Premium only.
compatibility: Needs the Snipd MCP server (`uploads_initiate`, `uploads_list`, `uploads_delete`), a shell with `curl`, and `yt-dlp` (installed only with the user's consent). `ffmpeg` is optional.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Import a YouTube video into Snipd

Same flow as the `upload-file` skill, with the audio and the metadata coming from YouTube. The
Snipd app sends the video's title, description, channel, URL, thumbnail and language with the
upload, and the episode is built from them: the thumbnail becomes the cover, the language steers
the transcription. Do the same.

One rule matters: Snipd fills the metadata in from the video itself **only when the upload carries
none of it**. As soon as you pass one field, only what you pass is used. So pass the full set below,
or nothing at all.

## Steps

1. **Check the URL.** Accept `youtube.com/watch?v=...`, `youtu.be/...`, `/shorts/...` and `/live/...`
   links. For a playlist link, ask which video; import one video per run.
2. **Check the tools.** Run `yt-dlp --version`. If it is missing, explain that it is needed to read
   and download the video and ask before installing it: `brew install yt-dlp` on macOS, otherwise
   `pipx install yt-dlp` (or `python3 -m pip install --user yt-dlp`). Never install without a yes.
   `ffmpeg` is only needed for `-x` (re-encoding); the commands below work without it.
3. **Read the metadata** without downloading anything:

   ```bash
   yt-dlp --skip-download --no-playlist --dump-single-json "<video url>" > "<tmpdir>/video.json"
   ```

   Take from the JSON, and map to `uploads_initiate`:

   | JSON field | Tool input | Notes |
   |---|---|---|
   | `title` | `title` | |
   | `channel` (else `uploader`) | `author` | |
   | `description` | `description` | Cut to 5000 characters. |
   | `thumbnail` | `thumbnail_url` | Becomes the episode cover. |
   | `webpage_url` | `source_url` | The canonical video URL. |
   | `language` | `language` | See below. |

   **Language.** Use the JSON `language` field when it is set. When it is null, do what the app does
   and infer the spoken language from the auto-generated captions: among the keys of
   `automatic_captions`, take the one ending in `-orig` (e.g. `en-orig` → `en`); if there is none
   and exactly one key exists, take that key; otherwise leave `language` out and Snipd detects it
   from the audio. Never guess a language from the title.
4. **Check the space.** Call `uploads_list` with `status: "pending"` and compare `quota.available_mb`
   with the video: audio is roughly 1 MB per minute (`duration` in the JSON is in seconds). Warn
   the user and stop if it will not fit.
5. **Download audio only** into the temporary directory:

   ```bash
   yt-dlp --no-playlist -f "bestaudio[ext=m4a]/bestaudio" \
     -o "<tmpdir>/%(id)s.%(ext)s" "<video url>"
   ```

   Note the resulting file path, its size in bytes (`stat -f%z` on macOS, `stat -c%s` on Linux)
   and its MIME type (`m4a` → `audio/mp4`, `webm` → `audio/webm`, `opus`/`ogg` → `audio/ogg`,
   `mp3` → `audio/mpeg`). If yt-dlp fails (private, age-restricted or geo-blocked video, no
   network), relay its error and stop.
6. **Settle the options** as in `upload-file`: `type` (`lecture`, `podcast`, ... default `other`)
   and the one-sentence heads-up that AI processing is on by default and uses AI credits, with the
   option to turn it off.
7. **Initiate** with `uploads_initiate`: `file_name` (use `<title>.<ext>`, the title trimmed to a
   sane file name), `content_type`, `file_size_bytes`, `type`, `process_ai`, `source: "youtube"`,
   and the whole metadata set from step 3: `source_url`, `title`, `author`, `description`,
   `thumbnail_url` and `language` (omit only fields that are genuinely empty). Relay the Premium
   or quota refusal verbatim if you get one, and stop.
8. **Upload the bytes** with the same `curl -X PUT --upload-file` call as in `upload-file`, using the
   returned `content_type` and `upload_url`.
9. **Clean up**: delete the downloaded audio and the JSON from the temporary directory.
10. **Report** as in `upload-file`: uploaded, processing now, appears in the app under *Uploads* with
    the video's title and thumbnail when done; give the `upload_id`.

## Rules

- Only import videos the user is allowed to use this way; do not bulk-download playlists or channels.
- Do not install or upgrade anything on the user's machine without asking first.
- If the download succeeded but the upload failed, keep the local file until the user decides
  whether to retry, then remove it.
