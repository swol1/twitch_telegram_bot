# syntax = docker/dockerfile:1

# Use a specific version of ruby from slim image for reduced size
ARG RUBY_VERSION=3.3.0
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

ENV APP_PATH="/twitch_telegram_bot"

# Set the working directory
WORKDIR $APP_PATH

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libsqlite3-0 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set environment variables for production
ENV RACK_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Build stage for installing dependencies and building gems
FROM base AS build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Final stage for app image
FROM base
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build $APP_PATH $APP_PATH

# Setup non-root user and set ownership
RUN groupadd --system --gid 1000 twitch_telegram_bot && \
    useradd twitch_telegram_bot --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R twitch_telegram_bot:twitch_telegram_bot db log storage tmp
USER 1000:1000

ENTRYPOINT ["/twitch_telegram_bot/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["bundle", "exec", "puma"]