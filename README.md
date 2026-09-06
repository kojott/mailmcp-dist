# mailmcp 0.4.2

Your mail in ChatGPT, Claude and other MCP clients: Gmail, Outlook, iCloud, Fastmail, Yahoo, Zoho, Seznam.cz, Volný.cz and any IMAP/SMTP server. Mailbox passwords are encrypted in the user's browser and the server stores nothing.

This is the **prebuilt distribution** (minified files in `dist/`). The source code is available to customers on request. Running it requires a licence key: **https://mailmcp.ai/pricing** (Personal €4.99, Unlimited €129, one-time, 60-day refund).

## Deploy to Vercel (one click)

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fkojott%2Fmailmcp-dist&env=MAILMCP_KEY,MAILMCP_LICENSE&envDescription=MAILMCP_KEY%3A%2032%20random%20bytes%20base64url.%20MAILMCP_LICENSE%3A%20your%20license%20key.&project-name=mailmcp&repository-name=mailmcp)

1. `MAILMCP_KEY`: 32 random bytes as base64url, e.g. `node -e "console.log(require('crypto').randomBytes(32).toString('base64url'))"` (or the generator on `/start`).
2. `MAILMCP_LICENSE`: the `mml1.…` key from your purchase (exchange the Lemon Squeezy key at https://mailmcp.ai/claim).
3. After deployment open `https://<project>.vercel.app/start` and follow the guide. Users create their tokens on `/setup`.

Changing `MAILMCP_KEY` invalidates every token.

## Docker / your own server

```bash
docker build -t mailmcp .
docker run -d -p 8080:8080 -e MAILMCP_KEY=… -e MAILMCP_LICENSE=… -e MAILMCP_PUBLIC_URL=https://mail.example.com mailmcp
```

Without Docker: Node 22+, `node dist/node.js` with the same variables. Behind a reverse proxy set `MAILMCP_PUBLIC_URL` (or `MAILMCP_TRUST_PROXY=1`).

## Claude Desktop

Download `mailmcp.mcpb` from [Releases](https://github.com/kojott/mailmcp-dist/releases/latest), open it in Claude Desktop, paste the configuration from `/setup` (Claude Desktop mode) and the licence key.

## Optional variables

See `.env.example`: `MAILMCP_INVITE_CODE` (closed token registration), `MAILMCP_CONFIG` (the operator's own mailboxes, single-owner mode), `MAILMCP_PUBLIC_URL`, `MAILMCP_VIDEO_URL` (install video on the home page).

## Updates

A new version = a new tag in this repository. On Vercel: add this repository as upstream (`git remote add upstream https://github.com/kojott/mailmcp-dist && git pull upstream main && git push`) or click Deploy again. Docker: `git pull && docker build`. Updates are included up to version 1.0.

## Documentation and support

- Guide: `/start` on your server, the detailed guide at `/docs`, instructions for AI assistants at `/llms.txt`
- Support: https://jiridolejs.cz/kontakt
- Licence: `LICENSE` (EULA; English translation first, the Czech original governs). Not open source: redistribution and running without a key are prohibited.
