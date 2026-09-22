# Changelog

## 0.8.0 (2026-09-23)

### Before you upgrade (breaking)

A server that issues user tokens (`MAILMCP_KEY` without an owner configuration, which is what the one-click Vercel deploy sets up) **stops issuing tokens after the update** until you set one of these variables:

- `MAILMCP_INVITE_CODE`: a code of at least 8 characters, for example `KX7P-2MQR-9TWD`. Whoever creates a token on `/setup` (or signs in with Microsoft there) has to type it, so strangers cannot add mailboxes to your server. Give it only to the people who should use the server.
- or `MAILMCP_OPEN_SIGNUP=1`, only if you deliberately run a public server that anyone may use.

On Vercel: open the project → **Settings → Environment Variables** → add `MAILMCP_INVITE_CODE` for **Production** → save, then deploy 0.8.0 (or **Deployments → … → Redeploy** if the update is already deployed, since variables apply to new deployments only). With Docker or on a VPS, add the variable to your `.env` or `docker run -e` and restart.

What does not change: **tokens already issued keep working**, including in Claude and ChatGPT connectors; owner mode (`MAILMCP_CONFIG`) and Claude Desktop (`.mcpb`) need nothing. Until the variable is set, `/setup` shows the operator a notice instead of issuing a token, and `/api/seal` answers 403.

Optional, for Outlook: personal Outlook.com accounts sign in with a code on any server without further setup. For work or school Microsoft 365 accounts on your own server, register your own Microsoft app and set `MAILMCP_MS_CLIENT_ID` + `MAILMCP_MS_REDIRECT=1` (steps in `/docs`, chapter Outlook, "Work accounts on your own server"), because new Microsoft 365 tenants block sign-in with a code.

### Changes

- **Outlook.com and Microsoft 365 mailboxes**, through a Microsoft sign-in and Microsoft Graph instead of a password over IMAP/SMTP. The setup page offers "Sign in with Microsoft" for the provider Outlook / Microsoft 365: a popup with the account picker where the server's origin is a registered redirect URI (mailmcp.ai, or your own Entra app with `MAILMCP_MS_CLIENT_ID` + `MAILMCP_MS_REDIRECT=1`), otherwise a short code: the page first asks for a personal account (typed at microsoft.com/link) or a work or school account (login.microsoft.com/device). The popup pre-fills the address typed on the page and offers "Use another account", so a second mailbox needs no private window. Work accounts on a self-hosted server usually need the operator's own Entra registration (new Microsoft 365 tenants block sign-in with a code); `/docs` has the steps, with the redirect URI under "Mobile and desktop applications". The sign-in is gated by the same invite code as token creation, and the device-code relay requires one even on a server running with `MAILMCP_OPEN_SIGNUP=1`. The consented Microsoft permissions follow the mailbox capabilities: `Mail.Read` for a read-only mailbox, `Mail.ReadWrite` + `Mail.Send` for anything more, so widening capabilities later needs a new sign-in. At most **3** Outlook mailboxes per token (refresh tokens are large and the token travels in a request header). Shared mailboxes and send-as aliases are not supported.
- A Microsoft sign-in is good for **about 90 days**; the date is shown on `/setup` and returned by `list_accounts` as `reauth_by`. A client that refreshes its connection through our own OAuth (claude.ai, Claude Code, ChatGPT when it refreshes) carries the renewed Microsoft sign-in: each Outlook refresh token is rolled and the user token re-sealed. Other clients holding the same token keep the original one and reach the ceiling on their own schedule. Removing capabilities from a mailbox does not shrink the permission already granted at Microsoft; sign in again with fewer ticked, or revoke the app at Microsoft. Bearer-token clients sign in again: load the token with the edit password, "Sign in again", generate the token.
- Kill switches: `MAILMCP_MS_DISABLED=1` hides the Microsoft sign-in and answers 404 on every `/api/ms/*` route; `MAILMCP_DISABLE_GRAPH=1` refuses Outlook mailboxes at runtime, including in tokens already issued.
- **Breaking:** a server that issues user tokens now requires `MAILMCP_INVITE_CODE` (at least 8 characters), or `MAILMCP_OPEN_SIGNUP=1` for a deliberately public server. Without either, `/api/seal` and the Microsoft sign-in routes answer 403 and `/setup` shows a notice for the operator. Tokens already issued keep working.
- `uid` is accepted as a string as well as a number, because Graph message ids are opaque strings. A move returns `moved_uid`, the id to use afterwards.
- Send results carry `saved_to_sent`: `true`, `false` when filing the Sent copy failed, or `null` when the provider files it itself. Zoho now files its own copy (like Gmail and Graph) instead of getting a duplicate.
- Composing refuses a body or subject containing tool-call markup (`<invoke`, `<function_calls`, `<parameter name=` and friends), which is leaked model output rather than text a person meant to send.
- Special folders are also recognised under their Spanish, Portuguese, French, German, Italian, Dutch and Polish names on servers that advertise no SPECIAL-USE, so Sent and Drafts are found instead of created a second time in English.
- `get_attachment` returns the extracted text of PDF attachments up to 5 MB (20 000 characters, `text_source: "pdf"`), wrapped as untrusted like any body; the text can contain passages invisible in the rendered document, and a scanned PDF with no text layer keeps the download link.
- stdio only: `get_attachment` takes `save_to`, a directory inside `policy.attachment_dirs`, and writes the file there instead of returning bytes.
- The Claude Desktop build asks GitHub once per start whether a newer release exists and tells the assistant; `MAILMCP_NO_UPDATE_CHECK=1` opts out.
- `/docs`, `/privacy`, `/terms`, the audit document, the home page and `/llms.txt` describe all of the above, including where to revoke a Microsoft sign-in and the admin-consent link for tenants that restrict user consent.

## 0.7.9 (2026-09-22)

- The OAuth sign-in page (what ChatGPT and Claude show when you connect the server) explains where the token comes from: a collapsible "Where do I get the token?" with the three setup steps, a link to this server's `/setup`, the invite-code note and a reminder to keep the token safe.

## 0.7.8 (2026-09-19)

- Serves `/.well-known/microsoft-identity-association.json` with the id of the vendor's Entra app "mailmcp" (publisher-domain proof for the upcoming Microsoft sign-in). `MAILMCP_MS_CLIENT_ID` overrides the id for operators with their own registration.

## 0.7.7 (2026-09-17)

- `get_message` and `get_attachment` (text-like files) now carry the body in `structuredContent.text` as well, wrapped as untrusted content exactly like in `content`. Clients that hand the model `structuredContent` when it is present (Claude Code) saw only headers, `body_chars` and `truncated`; Codex, which reads `content`, was unaffected.

## 0.7.6 (2026-09-16)

- Over stdio, `MAILMCP_KEY` on its own (the HTTP server's token mode) no longer stops the server: it starts with zero mailboxes like a fully unconfigured one, so catalog runners and reviewers that set only the key still get the tool list.

## 0.7.5 (2026-09-16)

- The distribution package is named `mailmcp-dist` (was `mailmcp`), so directories no longer link the listing to the unrelated npm package of that name. The `mailmcp` CLI name and every entrypoint are unchanged.

## 0.7.4 (2026-09-16)

- The stdio server starts without any configuration: it lists every tool with zero mailboxes and each mailbox call explains that the owner creates the configuration on the setup page. Catalog checks (Glama) and reviewers can introspect the `.mcpb` before configuring it; a present but broken configuration still fails on start.

## 0.7.3 (2026-09-16)

- Catalog groundwork: `/privacy` and `/terms` pages (linked from the footer, the MCPB manifest and llms.txt), `/.well-known/mcp-registry-auth` (official MCP Registry domain verification, line from `MAILMCP_REGISTRY_AUTH`), `/.well-known/glama.json` (Glama ownership claim) and `/.well-known/mcp/server-card.json` (static server card with every tool and schema, built from the real server, for directories that cannot pass the OAuth gate).
- The distribution build writes `server.json` (hosted endpoint + MCPB release with its SHA-256) and `pnpm dist:push` publishes it to the official MCP Registry when `mcp-publisher` is logged in.
- MCPB manifest lists all tools (it had stopped at 0.4.0), plus homepage, documentation, support and privacy policy.

## 0.7.2 (2026-09-15)

- Signature with a photo or logo without putting it into the token: tick "signature from my mailbox" on the setup page and keep the signature as the newest message in the mailbox folder `mailmcp-signature` (send it to yourself from your mail client, or hand the HTML to the assistant: new tools `get_signature` / `set_signature`). Its inline images are embedded in every reply; nothing is stored on the server.
- Inline (cid) images inside HTML mail are no longer listed as attachments.
- IMAP connection failures are logged (without secrets) and explained to the assistant with the fix: revoked Gmail app password, missing app password, IMAP disabled, network problems.

## 0.7.1 (2026-09-15)

- Replies stay in the thread: new tools `reply_draft` and `reply_send` take the uid of the message being answered and the server sets In-Reply-To/References, keeps the "Re:" subject, picks the recipients (sender, or everyone with `reply_all`) and quotes the original under the reply, as plain text and as an HTML `<blockquote type="cite">`. `create_draft`/`send_message` with `in_reply_to_uid` do the same. Previously a reply could land as a new, unthreaded message when the assistant skipped the threading parameter.
- HTML alternative for every composed message, optional `html` body parameter.
- Per-mailbox signature (`signature_text`, optional `signature_html`) on the setup page; appended under every reply and draft.
- Assistant instructions and `llms.txt` teach the command vocabulary: "napiš mi odpověď / navrhni" = suggestion in the chat only, "odpověz / napiš koncept" = draft in the thread, "pošli / odešli" = send (when allowed).

## 0.7.0 (2026-09-12)

- New visual direction ("Signál"): the original red accent on a warm off-white ground, Archivo, rounded cards and buttons, white navigation with a free-connect button, an ink-black closing band; the black masthead strip and most 2 px rules are gone. New Open Graph image.
- Web redesign around the personas: a seven-section home page (hero without jargon, who it is for, one ordinary day, three steps, why not the official connector, three promises, price and FAQ), new `/teams` (companies and their IT), `/security` (the technical depth moved off the home page) and `/deploy` (own-server wizard moved off `/start`), `/start` with a "Will it work for me?" compatibility block and the install video, navigation "Connect / For teams", vendor in the footer (Swinging Dogs s.r.o., DIČ CZ24825671).
- Prices: Free on mailmcp.ai is 2 mailboxes per token with the signature (tokens from before 0.7.0 keep 5); Personal €19 once for your own server or Claude Desktop; Unlimited €149 once per server; deployment with onboarding €990 (Unlimited included). Earlier €4.99 buyers owe nothing. Workshop code −€10. Groundwork for a future hosted plan (licence keys may carry an expiry; a Personal key can be sealed into a token) ships unused.
- Outlook.com and Microsoft 365 removed from provider lists (passwords are not accepted by Microsoft); listed as "not yet" in the compatibility block.
- `llms.txt` and the guide updated (Stripe instead of the stale Lemon Squeezy mention).

## 0.6.5 (2026-09-11)

- Home page and guide: a "what it protects, what it reduces, what it cannot solve" section; the audit's residual risks gain the point that content the assistant has read can leave through the assistant's own reply or other tools.

## 0.6.4 (2026-09-11)

- Link previews: Open Graph and Twitter tags on every page with an English title and description and a 1200x630 image served at /og.jpg (WhatsApp, iMessage, Slack, LinkedIn showed a Czech text and no picture).

## 0.6.3 (2026-09-11)

- Home page: the install video embed sends a referrer to YouTube (the site's no-referrer policy made the player fail with error 153); chapter times and copy match the published film.

## 0.6.2 (2026-09-10)

- `LICENSE_REPLY_TO` sets the Reply-To of the licence key e-mails.

## 0.6.1 (2026-09-10)

- Refund period is 14 days, no questions asked (EULA, pricing, home page, guide, licence e-mail).

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
