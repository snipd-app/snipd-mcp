---
name: upload-file
description: Use when the user wants to upload, import or sideload a local audio or video file (mp3, m4a, wav, aac, flac, ogg, mp4, ...) into their Snipd account so it becomes an episode they can listen to and snip. Snipd Premium only.
compatibility: Needs the Snipd MCP server (tools `uploads_initiate`, `uploads_list`, `uploads_delete`) and a shell with `curl`. If the tools are missing, follow the `snipd-connect` skill first.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Upload a file to Snipd

Snipd's upload feature (the app calls it *sideload*) turns an audio or video file into a private
episode: the user can listen to it, snip it and, with AI processing, get a transcript and AI notes.
Every user has 20 GB of upload space; pending uploads count against it.

The MCP server never sees the file. `uploads_initiate` reserves space and returns a signed
Cloud Storage URL; **you** PUT the bytes there from the user's machine.

## Steps

1. **Check the file.** It must exist and be audio or video. Read the exact size in bytes
   (`stat -f%z "<path>"` on macOS, `stat -c%s "<path>"` on Linux) and pick the MIME type from the
   extension:

   | Extension | `content_type` |
   |---|---|
   | mp3 | `audio/mpeg` |
   | m4a, aac in mp4 | `audio/mp4` |
   | wav | `audio/wav` |
   | aac | `audio/aac` |
   | flac | `audio/flac` |
   | ogg, oga, opus | `audio/ogg` |
   | webm (audio) | `audio/webm` |
   | mp4, m4v | `video/mp4` |
   | mov | `video/quicktime` |
   | webm (video) | `video/webm` |

   Anything else: tell the user Snipd takes audio and video files and stop.
2. **Settle the options, once.** Only ask what is not obvious from the request:
   - `type`: `podcast`, `book`, `recording`, `lecture` or `other` (default `other`).
   - `language`: ISO 639-1 code (`en`, `de`, ...) when the user knows it; otherwise omit it and
     Snipd detects it.
   - `title`: shown in the app; omit to derive it from the file name.
   - `process_ai`: **on by default** and it uses the user's AI credits. Say so in one sentence and
     let the user opt out (`process_ai: false`) before you initiate. Do not ask again for the same
     upload.
3. **Initiate.** Call `uploads_initiate` with `file_name` (with extension), `content_type`,
   `file_size_bytes` and the options above. Handle the two expected refusals by relaying the tool's
   message and stopping: the account is not on Premium, or the file does not fit the free space
   (offer `uploads_list` to show what is taking it).
4. **Upload the bytes.** Use exactly the `content_type` the tool returned:

   ```bash
   curl -sS --fail-with-body -X PUT \
     -H "Content-Type: <content_type from the tool>" \
     --upload-file "<path>" \
     "<upload_url from the tool>"
   ```

   The URL is bound to that Content-Type and valid for 24 hours; send the raw file as the body and
   nothing else. Success is an HTTP 200 with an empty body. On failure, report the status and body,
   do not retry more than once, and offer to remove the now-stale upload with `uploads_delete`
   (after the user confirms) before trying again from step 3.
5. **Report.** Tell the user the file is uploaded, that Snipd is now processing it, and that the
   episode appears in the Snipd app under *Uploads* when processing finishes (minutes for short
   files, longer for multi-hour audio). Give them the `upload_id` and say they can check on it with
   the `upload-check-pending` skill.

## Rules

- Upload only when the user asked for it, and only the file they named. One file per
  `uploads_initiate` call.
- Never change the returned `content_type`, never put the file in a form field, never share the
  signed URL anywhere else.
- You do not need to read or transcribe the audio yourself; Snipd does that.
- Nothing here deletes or changes existing content in the user's account.
