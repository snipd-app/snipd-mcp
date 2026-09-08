---
name: upload-check-pending
description: Use when the user asks whether their Snipd uploads are done, what happened to an upload, why an upload failed, or wants to clean up stuck or failed uploads.
compatibility: Needs the Snipd MCP server (`uploads_list`, `uploads_delete`).
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Check pending Snipd uploads

1. Call `uploads_list` with `status: "pending"`.
2. For each pending upload report its title (or file name), status, age (now minus `uploaded_at`),
   size and, for errors, `error_reason`. Then one line on the quota (`available_mb` of `total_mb`).
   What the statuses mean:
   - `uploading`: Snipd has not received the bytes yet. Normal for a minute or two after an upload
     started; older than a day means the signed URL expired and the upload will never complete.
   - `processing`: Snipd is transcribing and preparing the episode. Long recordings take longer;
     more than a few hours usually means it is stuck.
   - `error`: processing failed; `error_reason` says why (unsupported codec, corrupt file, ...).
3. If nothing is pending, say so. If the user was waiting for a specific upload, call `uploads_list`
   with `status: "completed"`, find it by `upload_id` or title, and tell them which folder and
   episode it became.
4. Offer to delete uploads that are expired, stuck or failed. Delete only after the user confirms
   the specific upload, one `uploads_delete` call per upload, and report the result. Deleting a
   pending upload frees its reserved space; it never touches processed episodes.

Do not poll in a loop. If the user wants to wait for processing, suggest checking again later or
looking in the Snipd app, which notifies them when an upload is ready.
