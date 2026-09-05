# Changelog

## 0.3.0

- Self-hosted copies stay a storefront for the vendor; Personal runs token mode with a per-token cap
- Claim page enabled whenever the signing key is present (variant ids optional, name fallback)
- Lemon Squeezy integration: /claim exchanges LS keys for mailmcp keys (activate/validate), license_key_created webhook with HMAC check and optional e-mail delivery, setup guide, env wiring
- Proprietary EULA (Sendy-style, Czech governing + English): source visible, key required, no redistribution, 60-day refund, updates until next major; replaces AGPL
- Licensing (v0.3.0): no free tier, Ed25519 license keys verified offline, Personal €4.99 / Unlimited €129 / deployment €990, /pricing page, license page for unlicensed servers, deploy flow with two keys
- Copy pass: bilingual homepage that sells (hero, moment, permissions, FAQ, company band), sharper /start, /setup, /docs and README leads
- Access tokens 30 days (ChatGPT does not refresh proactively), AGPL-3.0 license, /llms.txt guidance for AI assistants, robots.txt, design working files
- Security hardening after five-area audit (v0.2.1)
- Attachments as one-hour download links (/files), edit-password documentation everywhere
- Setup page: all placeholders follow the selected language
- Attachment download on by default (setup page and schema)
- Setup page redesign: bilingual CZ/EN, provider presets incl. Volný.cz, only e-mail + password required, advanced options collapsed
- Editing a token requires an edit password: /api/unseal no longer yields mailbox passwords to a token holder alone
- Edit an existing token: /api/unseal returns the blob key to the token holder, setup page prefills from a token
- Bilingual 3-minute start wizard at /start (CZ/EN), master key generator, Deploy to Vercel button
