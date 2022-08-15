# ZITADEL with Custom Domain Setup

[Zitadel](https://zitadel.com) with Custom Domain Setup

## Prerequisites
A [certbot](https://certbot.eff.org/) connected external volume, named `certificates`

Refer [here](https://github.com/maxswjeon/certbot-setup) to set up correctly

## How to Deploy
1. Set up .env as .env.template
2. Run `bootstrap.sh` to create config files
3. `docker compose up -d` to deploy
4. Login as `root@zitadel.{DOMAIN}` and `RootPassword1!`

Enjoy!
