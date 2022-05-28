FROM ruby:3.1.2-alpine

# set up workdir
RUN mkdir /circuitverse
WORKDIR /circuitverse

# install dependencies
RUN apk update -qq && apk add imagemagick shared-mime-info postgresql-dev

RUN apk --no-cache add nodejs yarn --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    && apk update && apk add --virtual build-dependencies build-base

COPY Gemfile /circuitverse/Gemfile
COPY Gemfile.lock /circuitverse/Gemfile.lock
COPY package.json /circuitverse/package.json
COPY yarn.lock /circuitverse/yarn.lock

RUN gem install bundler
RUN bundle install  --without production
RUN yarn config set network-timeout 300000 && yarn install --verbose

# copy source
COPY . /circuitverse
RUN yarn build

# generate key-pair for jwt-auth
RUN openssl genrsa -out /circuitverse/config/private.pem 2048
RUN openssl rsa -in /circuitverse/config/private.pem -outform PEM -pubout -out /circuitverse/config/public.pem
