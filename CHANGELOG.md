# Changelog

## 0.4.1 (2026-09-06)

Security release following the published audit (https://mailmcp.ai/audit).

- send_draft only sends messages flagged as drafts from the Drafts folder; it can no longer re-send and remove other messages.
- forward_message and send_draft require the read capability; list_uploads requires draft or send.
- policy.attachments = "metadata" now also disables download links and re-sending mailbox attachments.
- Attachment names, subjects and sender fields are sanitized before they reach the assistant; invisible Unicode is removed; the HTML part of a message is preferred over the plain-text part so the assistant reads what the user sees.
- Hidden-text detection covers <style> class/id rules, entity-encoded and commented styles, self-closing hidden elements, tiny fonts, near-white colours, zero-size boxes.
- Bcc is stripped from the wire copy of outgoing mail; oversized attachments fail loudly instead of being truncated silently.
- Token seals are bound to the configuration they were created for; tokens are validated strictly; the master key must be 32 bytes; expired tokens are refused even when cached.
- User tokens may not point at private or loopback mail hosts on public servers (MAILMCP_ALLOW_PRIVATE_MAIL_HOSTS=1 to allow).
- Request bodies are bounded; upload links require Content-Length and at most 10 files per request; container content types are stored as opaque files.
- Throttles trust proxy headers only behind a known proxy; unseal attempts have their own budget; authorization codes are bound to the host that issued them.
- Licence keys carry an e-mail fingerprint instead of the address; the Claude Desktop extension no longer honours a public-key override.
- Sending tools are annotated as destructive; recipients are capped at 50 per field.

## 0.4.0 (2026-09-06)

- Outgoing attachments: existing mailbox attachments, files written by the assistant, local files (Claude Desktop), files uploaded through a one-hour link.
- forward_message, send_draft, upload_attachment, request_upload, list_uploads.

## 0.3.0 (2026-09-05)

- Licence keys (Personal, Unlimited), Lemon Squeezy checkout, /claim.
- Redesigned website (mailmcp.ai), English guide, prebuilt distribution repository.

## 0.2.0 (2026-09-04)

- Shared token mode with split-key encryption, edit password, OAuth 2.1 for ChatGPT and claude.ai.

## 0.1.0 (2026-09-04)

- First release: IMAP/SMTP mail tools for MCP, Claude Desktop extension.
