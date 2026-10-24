# Pragmatic: small slim base, single apt layer, Node via copy (no nodesource GPG dance).
FROM ruby:4.0.2-slim

RUN apt-get update -qq \
  && apt-get install --no-install-recommends -y \
    build-essential git pkg-config cmake \
    libpq-dev postgresql-client \
    libvips imagemagick shared-mime-info \
    yosys \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=node:22-bookworm-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=node:22-bookworm-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && npm install -g yarn \
  && gem install bundler -v 4.0.10 --no-document \
  && node --version && yarn --version && bundler --version
