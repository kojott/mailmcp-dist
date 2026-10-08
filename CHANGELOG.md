# Changelog

## 0.13.7 (2026-10-08)

- For teams: the links in the data protection officer line (security overview, privacy policy, audit) now work; 0.13.6 rendered them as broken relative links.

## 0.13.6 (2026-10-08)

- Pages now tell link previews who published them (`author`, Swinging Dogs s.r.o.) and when (`article:published_time`, the release date); LinkedIn showed both as missing.
- `MAILMCP_FB_APP_ID` (optional, digits): adds `fb:app_id` to every page for Facebook link previews.
- For teams: the line for your data protection officer now links the security overview, the privacy policy and the published internal audit instead of promising a prepared package.

## 0.13.5 (2026-10-08)

- New link-preview image (`/og.jpg`) in the new website's style: the red-envelope photo, “All your mail in ChatGPT and Claude. Not just Gmail.” and the mark.

## 0.13.4 (2026-10-08)

- **New website.** The home page leads with the product: a clickable demo of the mailmcp card right under the headline, the first customers, a comparison with the built-in Gmail and Outlook connectors, the permission panel and the price. Photographs in a red-envelope series on the home, Connect, Pricing, For teams and Security pages.
- **/start rebuilt so nobody gets lost:** a three-step map, the install video, provider tabs that show only your provider's steps (Gmail, Seznam.cz, Outlook / Microsoft 365, iCloud, other), a clear "come back for step 3" after the token form, and a connection check at the end. ChatGPT steps now include installing the plugin and picking it with @; Claude steps follow the current Customize → Connectors flow. `/llms.txt` matches.
- One navigation and footer for all pages: Connect, Pricing, For teams, Security, Guide; a one-row menu with a Menu button on phones; a footer in columns.
- Copy corrections: the For teams and Security pages no longer claim that the admin can never see passwords, that nothing is ever stored or that mail content can never act as an instruction; they now describe what the server does and its limits.

## 0.13.3 (2026-10-06)

- `get_attachment` no longer advertises `save_to` on HTTP deployments (OpenAI plugin scan): it only ever worked over stdio, and a `save_to` sent to an HTTP server is still refused. Claude Desktop / Claude Code keep it.

## 0.13.2 (2026-10-06)

- `set_followup` and `snooze` are now marked `destructiveHint: true` (OpenAI plugin scan): snooze moves the message out of the Inbox and set_followup can replace or clear an earlier follow-up. Nothing is deleted; behaviour is unchanged.
- **ChatGPT:** Settings → Connectors → mailmcp → Refresh to load the updated tool hints.

## 0.13.1 (2026-10-05)

- `unsubscribe` is now marked `destructiveHint: true`: an executed unsubscribe cannot be undone from mailmcp, so assistants ask before running it. The default dry run is unchanged and changes nothing.
- **ChatGPT:** Settings → Connectors → mailmcp → Refresh to load the updated tool hints.

## 0.13.0 (2026-10-05)

The first release since 0.9.0. It brings together the work built as 0.9.1 (usage statistics), 0.10 (triage and bulk clean-up), 0.11 (follow-ups, snooze, templates, confirmed sends, unsubscribe), 0.12 (the clickable inbox) and 0.13 (protection levels for verification emails); none of those was released on its own. Tools: 21 → 33.

### Before you upgrade (self-hosted operators)

Behaviour changes:

- **Usage statistics, on by default on servers.** Every server copy (Vercel production, Docker, Node) now sends one small request a day to mailmcp.ai: `{"s":1,"v":"0.13","r":"docker","d":"…"}` (schema, version as major.minor, runtime, and a number that stays the same for a calendar month, computed from values that never leave your server). The answer tells your copy whether a newer version exists. No licence key, configuration, mailbox, address or content is sent. Turn it off with `MAILMCP_NO_STATS=1` (or `MAILMCP_STATS=0`, or `DO_NOT_TRACK=1`); the content-less update check stays. `MAILMCP_NO_UPDATE_CHECK=1` sends nothing to mailmcp.ai at all. Every copy logs one line at start saying whether statistics are ON or OFF. Details and the public totals: https://mailmcp.ai/stats.
- **Claude Desktop and other desktop (stdio) copies: statistics are off** unless you tick Settings → Extensions → mailmcp → **Anonymous usage statistics** (or set `MAILMCP_STATS=1`). The update check now asks mailmcp.ai instead of GitHub, at each start; untick **Check for updates** to send nothing at all.
- **Protection levels: existing tokens and configurations stay Off.** A configuration without a level behaves as before and `list_accounts` reports it as `set: false`. New mailboxes on /setup start at **Standard**. To turn protection on for a token: load it with its edit password on /setup, pick a level, save (Generate my token), then replace the token in every assistant (ChatGPT and claude.ai: remove the connector and add it again; other clients: put the new token in place of the old one). The old token stays valid and keeps the old level, and OAuth sign-ins last up to 90 days, so saving alone changes nothing for an assistant that still holds the old token. Then check `list_accounts`: `protection` must show the new level. A token without an edit password cannot be loaded: build a new one and replace the old one the same way. Configurations you write yourself (owner mode, a plain-text file, Docker, Claude Desktop): add `"protection": "standard"` (or `off`, `basic`, `strict`, or `{ "level": "custom", "categories": [...] }`) to each mailbox's `capabilities`, then restart or redeploy. There is no server-wide minimum level.
- **Panels switch.** The clickable inbox (MCP Apps) shows on `triage`, `digest`, `create_draft`, `reply_draft` and `bulk_preview` in apps that support it. Turn it off per token on /setup ("Panels in the app (Claude, ChatGPT)", then replace the token), with `policy.ui: "off"` in a configuration you write yourself, with `MAILMCP_UI=off` over stdio, or in Claude Desktop with the extension setting "Panels in Claude".
- **IMAP servers that support neither MOVE nor UIDPLUS now refuse archive, trash and move** (single and bulk), with a message saying to move the mail in the mail client. Before, a move on such a server could expunge other messages marked deleted in the same folder. Marking read, flags and Gmail labels are unaffected. Volný.cz and iCloud advertise neither capability before login; their post-login capabilities were not verified, so moves may be refused there.
- Moves and labels to Junk/Spam need the `delete` capability, like Trash.
- **Host-only sending is stored so that older servers refuse to send:** a mailbox set to "only after I confirm in my app's dialog" is written as `send: false` plus `send_host_only: true`; an older server or a rollback refuses to send from it instead of sending without the dialog.
- mailmcp keeps records in the owner's own mailbox (folders `mailmcp-state`, `mailmcp-snoozed`, `mailmcp-templates`), never on the server. New configurations get `policy.state_secret` (it signs those records; when absent it is derived from the key that decrypts the configuration) and `policy.timezone` from /setup. Plaintext configurations without any key (`MAILMCP_CONFIG_FILE` in development) cannot set follow-ups or snoozes or save templates: set `MAILMCP_KEY` or add `state_secret` to the policy.
- On mailmcp.ai, an expired subscription token with more mailboxes than Free allows now signs in in recovery mode: all its mailboxes are listed, and only clearing, waking and listing run until it is renewed.
- Licence agreement 1.2 (29 September 2026) adds clause 7.2 on the update check and statistics.

New optional environment variables (nothing new is required: no new service, no new runtime dependency):

- `MAILMCP_NO_STATS`, `MAILMCP_STATS`, `DO_NOT_TRACK` (statistics switches, accepting `1`, `true`, `yes`, `on` and, for `MAILMCP_STATS`, `0`, `false`, `no`, `off`); `MAILMCP_NO_UPDATE_CHECK` now means "no request to mailmcp.ai at all".
- `MAILMCP_UI=off` (stdio: no panels).
- `MAILMCP_ELICITATION_HOSTS`: apps proven to show the confirmation dialog (the built-in list ships empty).
- For ChatGPT to render the panels under your own origin, serve HTTPS and set `MAILMCP_PUBLIC_URL`, or run behind a trusted proxy (`MAILMCP_TRUST_PROXY=1`; Vercel counts as one). Without a trustworthy HTTPS origin the server advertises none and the text tools are unaffected.

Clients:

- **ChatGPT:** Settings → Connectors → mailmcp → **Refresh** (or remove and add it again). The tool list, the `bulk_apply` input and many tool descriptions changed, and ChatGPT keeps a snapshot of the old ones.
- **Claude Desktop:** reinstall `mailmcp.mcpb` to get the new tools, the panels and the new settings; the old extension keeps working.

### Rolling back to 0.9

- The protection level and the panels switch are ignored: 0.9 shows every message again, including verification emails. The fields stay in the configuration, so upgrading again brings them back.
- Gmail All Mail and Outlook whole-mailbox searches then show mailmcp's records and templates (bodies stay wrapped as untrusted data); snoozed mail stays in `mailmcp-snoozed` until you move it back in your mail client.
- Mailboxes set to send only after the app's dialog cannot send at all under 0.9 (by design).
- No statistics are sent; the Claude Desktop build asks GitHub for the latest release again.

### Fixed (bugs in 0.9.0)

- **Outlook / Microsoft 365: download and upload links failed with 502.** A `/files` or `/upload` link carries the encrypted token, 4 to 8 KB with an Outlook mailbox, and Vercel refuses a URL path over about 2 KB. Links are now `/files?r=…` and `/upload/?r=…`; the old path forms still work.
- **Gmail: archiving from INBOX did nothing** while reporting done (Gmail keeps a folder's own label when it is removed in that folder). Archive and label removal now act in All Mail and read the result back; bulk archive, `modify_message` and undo follow the message there.
- **`/pricing` said VAT is added at checkout for Personal (€19).** Personal and the mailmcp.ai subscription are priced including VAT; only Unlimited (€149) is shown without VAT, which checkout adds.
- `/files` answers a refusal by the mailbox with 422 and its reason instead of 502.
- Outlook / Microsoft 365: a folder with more than ten subfolders listed only ten of them, so a subfolder past the tenth was "Unknown folder".
- Safety: IMAP moves go only through UID MOVE, or UID COPY + a verified copy + `\Deleted` + UID EXPUNGE of exactly those messages; a plain EXPUNGE is never sent. `send_draft` removes only the sent draft, or leaves it in Drafts and says so when the server has no UIDPLUS or the Sent copy failed. Replacing the signature removes only signatures mailmcp stored itself. Consumed uploads are removed message by message. Outlook `send_draft` refuses a draft whose recipients or revision changed after the allowlist check. Outlook's Recoverable Items is refused as a destination. Flag, label and move changes check that the message is really there first (a stale IMAP session answered OK and changed nothing).

### New: protection levels for verification emails

- A per-mailbox level: Off, Basic (one-time codes, sign-in links, password and account recovery), Standard (Basic plus security alerts; the default for new mailboxes on /setup), Strict (Standard plus bank and payment mail) and Custom (ticked categories). Set only on the setup page or in the owner's configuration; no tool argument can change or widen it.
- The mailmcp server decides with fixed English and Czech rules, headers first and then the body on every path that returns or sends a body. It catches typical verification emails, not every possible one. Meeting passcodes stay visible. Booking, order, customer, access and error codes are not verification codes; amounts with decimals are never codes; mail from a person rather than a service is never hidden whole because of its body (its codes are removed from Standard up).
- Hidden mail is left out of searches, listings, triage, digests and follow-up lists; opening, forwarding, attaching, downloading, moving or trashing it by id is refused. Every search on a protected mailbox carries one constant protection line; plain listings and scans report `hidden_by_protection`, a count, never which messages.
- From Standard up, codes and sign-in links in other mail become `[code removed]` and `[sign-in link removed]`, text searches leave out mail that contains them, and the bytes of such mail cannot leave through `forward_message`, attachments or download links.
- At a hiding level a text search reads message bodies and readable attachments (text files, PDFs within the extractor's bounds, attached mail) and keeps a message only when its match is in analysed text; it pages up to offset 100, runs within a 30-second slice and returns `total_exact: false` when it stops early. A text search with a negation, a wildcard or an attachment or file-name operator leaves out mail with attachments. On Gmail, queries made only of `is:`, `in:`, `label:`, `category:`, date and size operators are listings and read no bodies. The ChatGPT `search` tool carries the protection line as `notice`.
- A code for signing in counts as a code whatever else qualifies it. A bank's own confirmations are banking, hidden only at Strict; a bank's code mail is a code at every hiding level. Attachment names are classified like subjects; an attachment is classified by the stricter of its declared type, its file name and its first bytes.
- `list_accounts` and `mailmcp://accounts` report `protection: { level, set, hides, redacts, rules }` per mailbox. The panels show "Hidden by the protection level: {n}", and a draft card whose draft contains a code or sign-in link the level hides does not send ("Send it from your mail app").

### New tools (21 → 33)

- `triage`: sorts recent mail into reply_candidates, waiting_on, newsletter, lists, calendar, automated and other from headers only, with the reasons and the coverage. Up to four mailboxes in parallel with `account: "all"`.
- `awaiting_replies`: threads where the owner wrote last and no reply was found.
- `digest`: what arrived since the last run, with a per-mailbox coverage cursor; without a cursor the last 24 hours.
- `bulk_preview` (read-only) and `bulk_apply`: archive, mark_read, label, move or trash many messages at once. The preview lists the exact messages and changes nothing; `bulk_apply` takes the preview's confirmation together with its action, mailbox and count and acts on exactly those messages, fewer if some changed. Free acts on 50 per call, paid plans on 500. Nothing is deleted. `bulk_preview batch=` shows what an applied batch did; `bulk_apply batch= undo=true` puts a batch back on paid plans within 7 days.
- `set_followup` and `list_followups`: a follow-up by a date, recorded in `mailmcp-state` and shown as a star, flag, label or category; due follow-ups across mailboxes, including flags set in Outlook itself. Setting is paid, clearing free.
- `snooze` and `wake_snoozed`: moves one message into `mailmcp-snoozed` until a time and brings it back where it was, unread. Snoozing is paid, cancelling and waking free.
- `save_template` and `list_templates`: text templates and a tone-only style profile in `mailmcp-templates`; `create_draft` and `reply_draft` take `template` and `vars`. Templates are paid, the profile free.
- `unsubscribe`: a dry run says whether mailmcp may send the RFC 8058 one-click request (only when the provider verified a DKIM signature covering both unsubscribe headers and the link is on the signer's own domain). Needs the `unsubscribe` capability, off by default.

### New: the clickable inbox (MCP Apps)

- One built-in page, `ui://mailmcp/app.html`, rendered by the host in its sandbox on `triage`, `digest`, `create_draft`, `reply_draft` and `bulk_preview`: an inbox list and a triage board, bulk previews and results, and a draft card. Czech and English, light and dark, usable at 360 px and by keyboard. `search_messages`, `get_thread`, `bulk_apply` and `unsubscribe` answer as text only.
- The draft card shows the sending mailbox, every recipient including Bcc, every attachment, the owner's own text, and which message a reply quotes or a forward forwards. Send takes two clicks: the first re-reads the draft and arms only if nothing changed; the second calls `send_draft` with that draft's fingerprint. Send stays off when the server would refuse it, when the draft was already sent (`already_sent`), when mailmcp has no record that lets the card show the owner's own text (`unreviewable`), and when the draft has HTML mailmcp did not generate (`html_differs`).
- The card is not a confirmation: every button is an ordinary tool call the server checks like the model's own. Only a mailbox set to send after the app's dialog (`send_host_only`) makes a send wait for the owner.
- The page loads nothing from the internet (empty CSP lists, mail as plain text only). It goes out gzip-compressed over `/mcp` when the app accepts it (about 140 KB instead of 650 KB).

### Changed

- `create_draft` and `reply_draft` return a fingerprint of the stored draft; `send_draft` takes `expect_fingerprint` and refuses a draft that changed since it was shown, and refuses a draft that was already sent.
- Confirmations in the app's own dialog (mode B) on apps known to show a confirmation form: sends, confirmed bulk actions, undo and unsubscribe first ask the owner there, with every recipient listed.
- Draft provenance is a record in `mailmcp-state`, never a header: mailmcp adds no header to mail it sends, and every send path strips `X-Mailmcp-*` headers.
- `search_messages` results carry header-based `hints`; `get_thread` searches across folders, reports `coverage` and returns bodies with `include_bodies`. Output schemas on the read tools; prompts `inbox_zero`, `daily_digest`, `follow_ups` ("Who owes me a reply"), `draft_replies`, `scheduled_recipes`.
- Shorter tool descriptions and argument texts (same rules, fewer words) keep the tool list within its context budget with twelve more tools.

### New: usage statistics on mailmcp.ai

- `/stats` shows what a copy sends (the exact request, a sample you can run that is never counted), when it is on, the switches, what is stored and for how long (hashed values until counted, at most 48 hours / 40 days; daily totals 400 days, monthly totals 25 months), the Redis commands verbatim, and the numbers: running copies per day and per month by version and runtime (rounded to 5). Copies of 0.13.0 and later only. Docker and Node send at a random time of day, Vercel on the first request of a day, Claude Desktop at start; nothing is sent between 23:50 and 00:10 UTC. A copy without a machine id writes a random salt once to `~/.mailmcp/stats-salt` and keeps the day of its last ping in `~/.mailmcp/stats-sent-*`; neither file is ever sent. The request has a 2-second timeout and never delays or breaks anything.
- MCP requests on mailmcp.ai are counted in Vercel Web Analytics by method (`initialize`, `tools/list`, `tools/call`; `server/discover` is not counted), tool, client family and outcome, with the time rounded to the hour; no IP address, cookie, client user agent, token or content. None of this exists in your own copy.
- Rulings for the receiver on mailmcp.ai: Upstash Redis free plan in Frankfurt (eu-central-1), no pay-as-you-go; a daily write budget of 860 accepted pings (`MAILMCP_STATS_DAILY_BUDGET`; the conservative figure that keeps a month under the free plan's 400,000 commands if Upstash bills each command inside the script); pings over the budget are answered and not counted, and `/stats` marks the day "capped".

### Not in this release

- In-card editing (`revise_draft`) and `respond_invite` are deferred. `schedule_send` is dropped: Microsoft 365 cannot cancel a deferred send.

### Known limitations

- Pictures and office files attached to visible mail are not scanned for codes. Bulk clean-up can move a message whose body is hidden (never delete it). Confusable characters outside the fold map are not caught. Download links remain bearer links for one hour.
- A sender can make their own mail disappear from the assistant (a fake "Security alert" is hidden, so the assistant cannot warn about it). Listings bisected by date reveal when hidden mail arrived, never its content.

### Pages

- `/docs` (Czech and English): the new tools and recipes, bulk clean-up, approvals, follow-ups and snooze, "What mailmcp keeps in your mailbox" and how to remove it, unsubscribing, the clickable inbox, "Verification emails and protection levels", and what the server sends where. `/llms.txt` and `/llms-full.txt` follow. `/privacy`: what lives in your mailbox, the update check and statistics with Upstash as processor, classification in memory. `/terms`, `/pricing`, `/security`, `/start` and the READMEs follow. Audit addenda 14 to 18.

### Build

- The distribution and the Claude Desktop extension contain the statistics sender only: the build fails if a vendor-only module (receiver, `/stats`, MCP counting) slips into a bundle, if the extension's statistics setting is not off by default, or if the Dockerfile lacks `MAILMCP_RUNTIME=docker`.

## 0.9.0 (2026-09-29)

### Before you upgrade (self-hosted operators)

- Every server that issues user tokens without a licence key (free tier) now enforces **10 sends per hour per mailbox** itself. This is not limited to mailmcp.ai: your own copy running Free in token mode (the one-click Vercel deploy without `MAILMCP_LICENSE`) gets the same ceiling. It applies to tokens already issued: a token whose configuration sets a higher `policy.send_rate_per_hour` is clamped to 10 from the first request after the update, without being re-created; the refusal reads "Send rate limit reached (10/hour, free tier ceiling)". Servers with a Personal or Unlimited key are unchanged: the configuration's rate applies. Owner mode and Claude Desktop (`.mcpb`) keep the configured rate.
- mailmcp.ai subscription keys do not license your own server: `MAILMCP_LICENSE` refuses them and `/setup` on your server has no field for them. Buy Personal or Unlimited for your own server.

- Licence agreement 1.1 (29 September 2026): Swinging Dogs s.r.o. is the licensor; Personal is one Running Installation for one user whoever owns the mailboxes, Unlimited one organization and its employees; serving other people's mailboxes or running mailmcp as a hosted service needs a separate agreement; the software ships as the built package only; licences are sold through Stripe as merchant of record; the 14-day refund covers each new purchase (not renewals); updates within the same major version; a material breach gets 14 days to cure; consumer rights are carved out clause by clause. The mailmcp.ai subscription is governed by https://mailmcp.ai/terms, not by the EULA.

- Terms of service rewritten (Czech binding): operator identity, Stripe as merchant of record, subscription seats, renewals and refunds per new purchase, suspension and termination, consumer carve-outs, how changes are announced; the privacy policy now lists the technical logs and in-memory data the server keeps.

### mailmcp.ai subscription

- New plan on the hosted service mailmcp.ai: **€49 per person per year**, bought for any number of seats (up to 50 in one checkout). Each seat gets its own subscription key: up to 10 mailboxes per token, no "Sent with mailmcp.ai" signature, 50 sends per hour per mailbox, one send quota per seat whichever token carries the key. The quota counts per mailbox address (renaming a mailbox in a new token does not reset it) and a seat sends at most 500 messages per hour in total. A token whose configuration leaves the send rate at the default of 10 gets the 50; `/setup` fills in 50 when a valid key is entered and 10 again when it is removed. A lower rate you set yourself stays.
- Keys are issued for paid invoice periods only and expire 30 days after the paid period ends. They arrive by e-mail and on `/claim` after checkout; every yearly renewal (Stripe charges automatically) e-mails new keys, and "Send my keys again" on `/claim` re-sends the current ones to the purchase address, throttled per address and per IP. The Stripe customer portal (card, invoices, cancellation) is linked from `/claim` and from the e-mails.
- Key e-mails (one-time licence keys and subscription keys: purchase, renewal, re-send) are in one language: English, or Czech when the purchase started on the Czech version of the site (the Stripe checkout page follows). Dates read "29 October 2027" / "29. října 2027" and the support contact is info@swingingdogs.com.
- `/setup` on mailmcp.ai has a subscription key field, shows the subscription's limits, and replaces the key of an existing token without the edit password (**Replace the subscription key only**, `/api/relicense`). `/api/unseal` also returns the key sealed in a token (token and edit password required, as before).
- `list_accounts` returns `plan`: the tier, the key's expiry and, within 30 days of it or after it, how to renew. When a key expires, a token with up to 2 mailboxes keeps working on the Free rules (signature, 10 sends per hour). A token with 3 to 10 mailboxes is refused at `/mcp` and at the OAuth sign-in, with a message that names the expiry date and the renewal steps. Either way the mailboxes stay in the token and work again once a new key is pasted in.
- Refunded, disputed or leaked subscription keys are revoked with `MAILMCP_REVOKED` (whole subscriptions or single seats) on the next deploy.
- `/pricing`, `/docs`, `/llms.txt`, `/terms`, `/privacy` and the EULA describe the subscription, only on the hosted service.
- Stripe webhook: refusals that will never succeed (revoked, cancelled or ended subscriptions) answer 200 so Stripe stops retrying; a renewal that is not paid yet stays retriable.

### Fixes

- The send-rate limiters no longer reset every quota at once past 5 000 tokens: the oldest per-token entry is evicted instead. Subscription seat quotas are kept apart, so new tokens never evict them.
- Subscription keys stay valid across a new major version; the major-version check applies to Personal and Unlimited keys only.

## 0.8.3 (2026-09-25)

- `get_attachment` with `save_to` (Claude Desktop, Claude Code) saves files up to `policy.max_download_bytes` (25 MB by default, like HTTP download links) instead of stopping at `policy.max_attachment_bytes` (2 MB). The 2 MB cap is meant for content pasted into the conversation; a file written to disk never enters it.

## 0.8.2 (2026-09-25)

- Claude Desktop: saving attachments to disk works without touching the configuration. The extension settings have a new field **Attachment folders** (Downloads by default); `get_attachment` with `save_to` writes the file itself, PDFs included, into one of them, and the assistant is told which folders it may use. Before, the only switch was `policy.attachment_dirs` inside the encrypted configuration, so the call failed and the assistant fell back to the PDF text. An update from an earlier version leaves the field empty (Claude Desktop applies the default only on a fresh install): pick the folder once in Settings → Extensions → mailmcp → Attachment folders and restart Claude Desktop.
- Other stdio clients (Claude Code, Cursor): `MAILMCP_ATTACHMENT_DIRS`, folders separated by `:` (`;` on Windows), adds to `policy.attachment_dirs`.

## 0.8.1 (2026-09-23)

### Before you upgrade (breaking for Outlook on your own server)

Microsoft sign-in on a self-hosted server now needs **your own Microsoft Entra app registration**: set `MAILMCP_MS_CLIENT_ID` (steps in `/docs`, chapter Outlook, "Microsoft sign-in on your own server"), and `MAILMCP_MS_REDIRECT=1` when your server's address is registered as a redirect URI. Without it `/setup` offers no Microsoft sign-in. The vendor's app "mailmcp" is used on mailmcp.ai only: under it any copy could relay sign-ins with a code, which is a phishing tool in our name. Outlook mailboxes that were already signed in with a code through the vendor's app keep working until their sign-in expires (about 90 days); a new sign-in with a code under the vendor's app is refused by Microsoft, so sign them in again through your own registration before then.

### Security

- The device-code sign-in (`/api/ms/device`, `/api/ms/poll`) runs only under the operator's own Entra app; under the vendor's app it answers 404 and the setup page hides it.
- OAuth sign-in: a refused user token counts against its own address only (10 per 15 minutes). The global cap of 30 per 15 minutes now applies to owner-password guesses only, so a few addresses can no longer lock every user of a shared server out of sign-in.
- Microsoft popup sign-in: start and callback are limited per address (10 and 20 per 15 minutes) without a global cap anyone could spend.

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
