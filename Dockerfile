FROM ruby:2.6.5

# set up workdir
RUN mkdir /circuitverse
WORKDIR /circuitverse

# install dependencies
RUN apt-get update -qq && apt-get install -y imagemagick && apt-get clean

RUN wget -qO- https://deb.nodesource.com/setup_8.x | bash - && apt-get install -y nodejs && apt-get clean

COPY Gemfile /circuitverse/Gemfile
COPY Gemfile.lock /circuitverse/Gemfile.lock

RUN gem install bundler
RUN bundle install  --without production


# copy source
COPY . /circuitverse
