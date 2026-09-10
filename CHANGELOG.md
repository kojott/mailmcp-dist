# Changelog

## 0.6.0 (2026-09-10)

- Purchases moved from Lemon Squeezy to Stripe Managed Payments: Stripe is the merchant of record, adds VAT for the buyer's country, e-mails the receipt and a PDF invoice, handles refunds and disputes. Companies tick "I'm purchasing as a business" and enter a VAT ID at checkout.
- New routes: `/api/checkout?tier=personal|unlimited` (starts the checkout; a self-hosted copy hands over to the vendor), `/claim?session_id=` (shows the key right after payment; the same purchase always yields the same key), `/api/claim` with an e-mail re-sends keys when SMTP is configured, `/api/stripe/webhook`.
- `scripts/stripe-setup.mjs` creates products, prices and the webhook endpoint idempotently. Environment: `STRIPE_SECRET_KEY`, `STRIPE_PRICE_PERSONAL`, `STRIPE_PRICE_UNLIMITED`, `STRIPE_WEBHOOK_SECRET`. The `LEMONSQUEEZY_*` variables are gone.

## 0.5.7 (2026-09-07)

- Gmail app passwords need 2-Step Verification: the exact Google message ("The setting you are looking for is not available for your account") is now explained on /start, /setup, /docs, the home FAQ, llms.txt and the README so people and assistants recognise it at once.

## 0.5.6 (2026-09-07)

- All tools are always listed. ChatGPT stores the tool list when a connector is added, so a token that gained sending rights later never saw send_message; now the list is complete from the start and a call the account does not permit fails with an error naming the missing capability.

## 0.5.5 (2026-09-07)

- Guide, /start and llms.txt: add the ChatGPT connector on the website rather than in the app, refresh the tool list after changing token rights, Automatic authentication with DCR as the fallback.

## 0.5.4 (2026-09-07)

- ChatGPT "Automatic" sign-in (Client ID Metadata Document): a failed fetch of the client document is no longer cached for ten minutes, so one transient error cannot lock every later attempt into "invalid request"; the error page now says what happened and suggests DCR as a fallback; refusals are logged with the reason.
- Free-tier signature shortened to "Sent with mailmcp.ai · your mail in ChatGPT and Claude".
- Connector description says that several mailboxes connect at once.

## 0.5.3 (2026-09-07)

- `OPENAI_APPS_CHALLENGE` serves the OpenAI plugin-directory domain verification token at /.well-known/openai-apps-challenge.

## 0.5.2 (2026-09-07)

- MCP serverInfo now carries title, description, website (mailmcp.ai) and icons so ChatGPT and Claude can show them on the connector page; the mark is served at /icon.png and /icon.svg.

## 0.5.1 (2026-09-07)

- Optional Vercel Web Analytics, per deployment: `MAILMCP_ANALYTICS_SCRIPT` injects the cookieless script served by the deployment itself. Unset by default; a self-hosted copy loads nothing and never reports to the vendor. CSP allows same-origin scripts for it.

## 0.5.0 (2026-09-06)

- Free tier: a server without MAILMCP_LICENSE runs in full with up to 5 mailboxes per token; every message the assistant composes (drafts, sends, forwards) ends with a "Sent with mailmcp.ai" signature (plain text after the "-- " delimiter, a link in the HTML part). Personal and Unlimited remove it.
- MAILMCP_SIGNATURE=1 forces the signature on a licensed server (used on the vendor's demo server).
- An invalid key still shows the licence page; a missing key no longer does.

## 0.4.2 (2026-09-06)

Second security release, after the independent second-model review (see /audit, section 12).

- Mail hosts named in user tokens are resolved before connecting; private answers are refused and the connection is pinned to the vetted address.
- Staged uploads are removed only from mailboxes the token may write to, and only if mailmcp staged them.
- A move to Trash through modify_message requires the delete capability; the staging folder is reserved.
- Send-rate limiters survive cache eviction; schema maxima cap what a token can configure.
- Body limits are enforced on the bytes actually read; uploads require Content-Length.
- Lemon Squeezy keys are accepted only for the configured variant ids (optional store pin); webhook events are marked handled after success.
- send_draft respects the attachment policy and is bounded; oversized attachments and drafts are refused instead of truncated (this fix had been described in 0.4.1 but had not shipped).
- The HTML part of a message is preferred over plain text (likewise).
- Sanitizer: hidden classes inside links, hidden image alt text, percent-form white text, invalid entities, deep nesting; invisible Unicode removed inside the untrusted wrapper.
- Setup form preserves policy fields it does not show when a token is loaded for editing; a send limit of 0 stays 0.
- forward_message available to draft-only configurations; local files opened once and checked through the same descriptor; Referrer-Policy no-referrer; Docker source build fixed; release assets immutable.

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
