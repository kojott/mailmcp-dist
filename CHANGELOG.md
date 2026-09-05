# Changelog

## 0.3.0

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
- Licensing (v0.3.0): no free tier, Ed25519 license keys verified offline, Personal €4.99 / Unlimited €129 / deployment €990, /pricing page, license page for unlicensed servers, deploy flow with two keys
- Copy pass: bilingual homepage that sells (hero, moment, permissions, FAQ, company band), sharper /start, /setup, /docs and README leads
- Access tokens 30 days (ChatGPT does not refresh proactively), AGPL-3.0 license, /llms.txt guidance for AI assistants, robots.txt, design working files
