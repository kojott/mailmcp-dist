# mailmcp 0.3.0

Vlastní pošta v ChatGPT, Claude a dalších MCP klientech: Gmail, Seznam.cz, Volný.cz, iCloud, Fastmail, Yahoo, Zoho i libovolný IMAP/SMTP. Hesla ke schránkám se šifrují v prohlížeči uživatele a server si nic neukládá.

Toto je **předpřipravená distribuce** (minifikované soubory v `dist/`). Zdrojový kód je k dispozici na vyžádání zákazníkům. Provoz vyžaduje licenční klíč: **https://mailmcp-three.vercel.app/pricing** (Personal €4,99, Unlimited €129, jednorázově, vrácení peněz do 60 dnů).

## Nasazení na Vercel (na klik)

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fkojott%2Fmailmcp-dist&env=MAILMCP_KEY,MAILMCP_LICENSE&envDescription=MAILMCP_KEY%3A%2032%20random%20bytes%20base64url.%20MAILMCP_LICENSE%3A%20your%20license%20key.&project-name=mailmcp&repository-name=mailmcp)

1. `MAILMCP_KEY`: 32 náhodných bajtů base64url, např. `node -e "console.log(require('crypto').randomBytes(32).toString('base64url'))"` (nebo generátor na `/start`).
2. `MAILMCP_LICENSE`: klíč `mml1.…` z nákupu (výměna klíče Lemon Squeezy na https://mailmcp-three.vercel.app/claim).
3. Po nasazení otevřete `https://<projekt>.vercel.app/start` a postupujte podle průvodce. Uživatelé si tokeny vytvářejí na `/setup`.

Změna `MAILMCP_KEY` zneplatní všechny tokeny.

## Docker / vlastní server

```bash
docker build -t mailmcp .
docker run -d -p 8080:8080 -e MAILMCP_KEY=… -e MAILMCP_LICENSE=… -e MAILMCP_PUBLIC_URL=https://mail.firma.cz mailmcp
```

Bez Dockeru: Node 22+, `node dist/node.js` se stejnými proměnnými. Za reverzní proxy nastavte `MAILMCP_PUBLIC_URL` (nebo `MAILMCP_TRUST_PROXY=1`).

## Claude Desktop

Stáhněte `mailmcp.mcpb` z [Releases](https://github.com/kojott/mailmcp-dist/releases/latest), otevřete v Claude Desktop, vyplňte konfiguraci ze `/setup` (režim Claude Desktop) a licenční klíč.

## Volitelné proměnné

Viz `.env.example`: `MAILMCP_INVITE_CODE` (uzavřená registrace tokenů), `MAILMCP_CONFIG` (schránky provozovatele, jednouživatelský režim), `MAILMCP_PUBLIC_URL`.

## Aktualizace

Nová verze = nový tag v tomto repozitáři. Na Vercelu: v projektu nastavte tento repozitář jako upstream (`git remote add upstream https://github.com/kojott/mailmcp-dist && git pull upstream main && git push`) nebo klikněte Deploy znovu. Docker: `git pull && docker build`. Aktualizace jsou v ceně do verze 1.0.

## Dokumentace a podpora

- Průvodce: `/start` na vašem serveru, příručka `/docs`, návod pro AI asistenty `/llms.txt`
- Podpora: https://jiridolejs.cz/kontakt
- Licence: `LICENSE` (EULA, česky a anglicky). Nejde o open source; šíření a provoz bez klíče smlouva zakazuje.
