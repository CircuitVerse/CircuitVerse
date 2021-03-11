FROM ruby:2.6.5-slim-buster

# set up workdir
RUN mkdir /circuitverse
WORKDIR /circuitverse

# install dependencies
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    gnupg2 \
    curl \
    less \
    git \
    imagemagick \
    libpq-dev \
  && apt-get clean \
  && rm -rf /var/cache/apt/archives/* \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*

COPY Gemfile /circuitverse/Gemfile
COPY Gemfile.lock /circuitverse/Gemfile.lock
COPY package.json /circuitverse/package.json
COPY yarn.lock /circuitverse/yarn.lock

RUN gem install bundler
RUN bundle install  --without production
RUN yarn install


# copy source
COPY . /circuitverse

# generate key-pair for jwt-auth
RUN openssl genrsa -out /circuitverse/config/private.pem 2048
RUN openssl rsa -in /circuitverse/config/private.pem -outform PEM -pubout -out /circuitverse/config/public.pem
