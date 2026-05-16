# Twitch Telegram Bot

Telegram bot that sends real-time notifications from Twitch with changes on streamers' channels. Telegram users can subscribe to their own list of streamers.

- **Bot URL**: [t.me/twitchoba_bot](https://t.me/twitchoba_bot)

## If you want to have no limits and have faster delivery you can run it locally or deploy to your own server

### 1. Clone the Repository

```bash
git clone https://github.com/swol1/twitch_telegram_bot.git
cd twitch_telegram_bot
```

### 2. Copy the Environment Template

- I want to run locally:

```bash
cp .env.local.template .env.local
```

- I want to deploy:

```bash
cp .env.template .env
```
Then fill in environment variables inside the .env.local or .env file.

### 3. Generate Your Own Secrets

You can use any token, for example:

```bash
openssl rand -hex 32
```

Generate tokens for:
- `TWITCH_MESSAGE_SECRET`
- `TELEGRAM_SECRET_TOKEN`

Generate secret values for database encryption (can be omitted):
- `DB_ENCRYPTION_PRIMARY_KEY`
- `DB_ENCRYPTION_DETERMINISTIC_KEY`
- `DB_ENCRYPTION_KEY_DERIVATION_SALT`

### 4. Create and Configure Your Twitch and Telegram Accounts

- Create a Twitch application at [Twitch Developers Console](https://dev.twitch.tv/console) and fill in the environment variables:
  - `TWITCH_CLIENT_ID`
  - `TWITCH_CLIENT_SECRET`

- Create your bot using [BotFather](https://t.me/botfather) on Telegram and fill in:
  - `TELEGRAM_TOKEN`

### 5. Configure HTTPS for Local Development

For example, you can use ngrok:
- Create an account at [ngrok](https://ngrok.com) and obtain your public URL.
- Fill in the environment variable:
  - `PUBLIC_API_URL=https://1111-11-111-111-111.ngrok-free.app`

### 6. Run the Services

- Start the web service:

```bash
bundle exec puma
```

- Start the Redis server:

```bash
redis-server
```

- Start the background jobs:

```bash
bundle exec sidekiq -r ./config/environment.rb
```

### 7. Check Register the Telegram Webhook at the end of this page

<br>

## Deployment with Kamal

This project uses Kamal 2 for deployment. The deploy config uses `kamal-proxy`,
TLS through the `proxy` section, app port `3000`, and Redis as an accessory.

### 1. Prepare Production Configuration

Copy the deploy sample configuration:

```bash
cp config/deploy.sample.yml config/deploy.yml
```

Fill in `config/deploy.yml` with your own service name, image, registry,
server IP, and `proxy.host`.

Create Kamal secrets locally:

```bash
mkdir -p .kamal
touch .kamal/secrets
```

Add these values to `.kamal/secrets`:

- `KAMAL_REGISTRY_USER`
- `KAMAL_REGISTRY_PASSWORD`
- `TWITCH_MESSAGE_SECRET`
- `TWITCH_CLIENT_ID`
- `TWITCH_CLIENT_SECRET`
- `TELEGRAM_TOKEN`
- `TELEGRAM_SECRET_TOKEN`
- `DB_ENCRYPTION_PRIMARY_KEY`
- `DB_ENCRYPTION_DETERMINISTIC_KEY`
- `DB_ENCRYPTION_KEY_DERIVATION_SALT`
- `PUBLIC_API_URL`
- `REDIS_PASSWORD`
- `REDIS_URL`
- `SENTRY_DSN`

`HOST_IP` is not a Kamal secret. Put the server IP directly in the ignored
`config/deploy.yml`.

### 2. Prepare the Server

Create a directory for the SQLite database volume:

```bash
mkdir -p /db
chown 1000:1000 /db
```

Kamal 2 creates its own Docker network and manages `kamal-proxy`, so you do not
need to create a custom Docker network or a Let's Encrypt file manually.

### 3. Deploy

Validate the local deploy config before changing the server:

```bash
kamal config
kamal secrets print | sed -E 's/=.*$/=[FILTERED]/'
```

For a new server:

```bash
kamal setup
```

When upgrading an existing Kamal 1 deployment, run the upgrade first. Do not
manually remove Traefik before this step.

```bash
kamal upgrade
kamal deploy
```

On subsequent deploys:

```bash
kamal deploy
```

## Register the Telegram Webhook

Replace `<TELEGRAM_TOKEN>`, `<PUBLIC_URL>`, and `<TELEGRAM_SECRET_TOKEN>` with your actual values:

```bash
curl -X POST "https://api.telegram.org/bot<TELEGRAM_TOKEN>/setWebhook?url=<PUBLIC_URL>/telegram/webhook&secret_token=<TELEGRAM_SECRET_TOKEN>"
```

Example:

```bash
curl -X POST "https://api.telegram.org/bot123456VERY-SECRET-TOKEN/setWebhook?url=https://1111-11-111-111-111.ngrok-free.app/telegram/webhook&secret_token=my_secret_token"
```

## Setup Sentry

You can receive sentry reports by providing `<SENTRY_DSN>`

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
