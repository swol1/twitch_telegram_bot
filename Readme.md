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

I used Kamal because I wanted to try it. I can't really recommend it mainly because random bugs occur. However, if you configure it properly, it can be quite convenient. Follow these steps to prepare for deployment:

### 1. Provide Your Additional Production ENVS

- `KAMAL_REGISTRY_USER=your_docker_registry_login`
- `KAMAL_REGISTRY_PASSWORD=your_docker_registry_password`
- `PUBLIC_API_URL=https://example.com`
- `HOST_IP=11.111.11.111`
- `REDIS_PASSWORD=password`
- `REDIS_URL=redis://:password@service-redis:6379/0`

### 2. Prepare for Deployment

- Copy the deploy sample configuration:

```bash
cp config/deploy.sample.yml config/deploy.yml
```

- Fill in the configuration file (`config/deploy.yml`) with your own data.

### 3. Deploy Using Kamal

Follow [Kamal's Documentation](https://kamal-deploy.org/docs/installation/) for detailed deployment instructions

- Setup Let's Encrypt

```bash
mkdir -p /letsencrypt && touch /letsencrypt/acme.json && chmod 600 /letsencrypt/acme.json
```

- Create a directory for your database:

```bash
mkdir /db
chown 1000:1000 /db
```

- Create a Docker network for your services:

```bash
docker network create -d bridge private
```

- Deploy:

On first run:
```bash
kamal setup
```
On subsequent runs:
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
