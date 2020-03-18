FROM ruby:2.6.5

# set up workdir
RUN mkdir /circuitverse
WORKDIR /circuitverse

# install dependencies
RUN apt-get update -qq && apt-get install -y imagemagick && apt-get clean

RUN wget -qO- https://deb.nodesource.com/setup_8.x | bash - && apt-get install -y nodejs && apt-get clean

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update
RUN apt install -y yarn
RUN yarn

COPY Gemfile /circuitverse/Gemfile
COPY Gemfile.lock /circuitverse/Gemfile.lock

RUN gem install bundler
RUN bundle install  --without production


# copy source
COPY . /circuitverse
