---
name: create-podcast-from-web-article
description: Turn a web article or blog post into a private Snipd podcast from its URL. Use when the user wants to listen to an article in Snipd.
metadata:
  mcp-server-url: https://mcp.snipd.com/mcp
---

# Create podcast from web article

Create a private episode in the signed-in user's Snipd Uploads from a web article. This workflow does not publish the episode or make it available to other people.

Requires access to the article URL and the Snipd MCP server's `text_to_podcast` tool.


## Get the article

1. If the user has not supplied a URL, ask for it. Open the URL and identify the main article. If the page has several possible articles or no clear main article, ask which content to narrate.
2. Extract the complete main article in its original order, including its title, substantive section headings. Exclude image captions, menus, ads, cookie notices, newsletter forms, related-reading blocks, comments, and repeated page chrome. Check the beginning and end for missing or accidental extra content.
3. Use the article's title and language. If there is no title, create a short, faithful one. Identify an article-specific hero or lead image and its public image URL when available. Check that it is the intended image rather than a logo, tracking pixel, or decorative site element. An author portrait or other clearly suitable image from the article is acceptable when the article has no hero image; omit `image_url` when no suitable image is found. Respect an image URL the user supplied.


## Choose whether Snipd should edit for speech

When sending the extracted article text to Snipd:

- Set `edit_for_speech=true` for a written article, blog post or similar. This is highly recommended: Snipd's AI makes small, targeted changes where written formatting or notation would be confusing if spoken aloud, such as headings, lists, and ambiguous numbers. It keeps the article's meaning, voice, order, and original wording and only adds very small single edits if needed.
- Set `edit_for_speech=false` for a script or text that is already optimized for text to speech. For example a script written by an AI with the intention of being spoken out loud word for word (e.g. a script for an AI-generated podcast). Do not turn speech editing on for such text.


## Send to Snipd

Use `text_to_podcast` with the complete extracted text, final `title`, supported article `language`, optional public `image_url`, and the chosen `edit_for_speech` value. The tool accepts at most 36,000 characters per request. For a longer article, split at natural section boundaries into separately titled, ordered parts without dropping text. Apply the same editing choice to each part. Do not submit the same part twice after an uncertain result: check Uploads or the tool's failure guidance first.

FYI: The `text_to_podcast` tool requires Snipd Premium.

The user's request to turn an article into a podcast authorizes generation. `estimate_only=true` is available if the user asks for an estimate of how many AI credits (="AI minutes") will be used by the generation; otherwise submit with `estimate_only=false`. If the Snipd tool is missing, follow `snipd-connect` to connect the server. If Snipd rejects the request for Premium, unsupported language, or insufficient credits, explain the result and stop. A minute of generated audio, including the subsequent AI processing of that generated audio, uses up roughly 10 AI credits (="AI minutes") from the user's Snipd account.

After `status: "accepted"`, say that the episode was submitted to the user's Snipd account and should appear in their Uploads folder in a couple of minutes. Report `estimated_total_ai_minutes` as an estimate rounded up to the next multiple of 10, unless it is below 10 in which case you round to the next integer; sum estimates for multiple parts. Call the units `AI credits (="Snipd's AI minutes").` If `edit_for_speech=true`, state that Snipd will make small edits to improve the listening experience for article characteristics that don't work well in audio such as lists or section headers, etc.. Use this **exact** wording:

> Estimated use: **130 AI credits** (=Snipd's "AI minutes").    
> Snipd's AI might make small edits to improve the listening experience such as introducing section headers with "next section" and similar small edits.

Where "130" has to be replaced by the actual number.

Never claim the episode is ready until Snipd confirms it.