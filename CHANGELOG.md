# Changelog

## 0.4.0

- Guide (/docs) in English with a Czech switch; upload pages no-store; English demo name
- 0.4.0: outgoing attachments
- Sales copy pass: official-connector comparison (verified), attachments and split-key pushed on home, pricing, start, setup and llms.txt
- Security review fixes: no owner mailboxes on the public home page, no-store on secret pages, generic errors, no licensee/e-mail echo, licence pubkey override compiled out of dist, honest wording and token lifetime in docs
- English README, Lemon Squeezy guide and distribution README; EULA reordered: English translation first, governing Czech original below
- Canonical domain mailmcp.ai: vendor URL, docs, dist README; old host redirects web pages, keeps MCP/OAuth
- Redesign every page in the Modernist design system from the owner's Claude Design canvas
- Setup form: Czech providers (Seznam.cz, Volný.cz) only in the Czech UI
- CLAUDE.md: every production update must also rebuild and push the dist repo
- Sign-in page CSP allows the client's redirect origin (Allow access did nothing in browsers); company deployment = 2 h online onboarding
- Prebuilt distribution repo: scripts/build-dist.mjs, buyer-facing links point to kojott/mailmcp-dist
- Self-hosted copies stay a storefront for the vendor; Personal runs token mode with a per-token cap
- Claim page enabled whenever the signing key is present (variant ids optional, name fallback)
- Lemon Squeezy integration: /claim exchanges LS keys for mailmcp keys (activate/validate), license_key_created webhook with HMAC check and optional e-mail delivery, setup guide, env wiring
- Proprietary EULA (Sendy-style, Czech governing + English): source visible, key required, no redistribution, 60-day refund, updates until next major; replaces AGPL
