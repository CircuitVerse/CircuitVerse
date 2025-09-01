FROM ruby:3.4.4

# install dependencies
RUN apt-get update -qq && apt-get install -y build-essential ca-certificates curl gnupg imagemagick shared-mime-info cmake cmake-data libvips libpq-dev pkg-config git \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
 && apt-get update && apt-get install -y nodejs && apt-get autoremove && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* \
 && npm install -g yarn
