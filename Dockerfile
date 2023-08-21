FROM ruby:3.2.1

# set up workdir
RUN mkdir /circuitverse
WORKDIR /circuitverse

# install dependencies
RUN apt-get update -qq && apt-get install -y imagemagick shared-mime-info libvips && apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && apt-get update && apt-get -y install cmake && rm -rf /var/lib/apt/lists/*

COPY Gemfile /circuitverse/Gemfile
COPY Gemfile.lock /circuitverse/Gemfile.lock
COPY package.json /circuitverse/package.json
COPY package-lock.json /circuitverse/package-lock.json

RUN gem install bundler
RUN bundle install  --without production
RUN npm install

# copy source
COPY . /circuitverse
RUN npm run build

# Solargraph config
RUN solargraph download-core
RUN solargraph bundle
RUN yard config --gem-install-yri

# generate key-pair for jwt-auth
RUN openssl genrsa -out /circuitverse/config/private.pem 2048
RUN openssl rsa -in /circuitverse/config/private.pem -outform PEM -pubout -out /circuitverse/config/public.pem
