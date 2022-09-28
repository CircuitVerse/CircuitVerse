ARG ruby_version=3.1

FROM ruby:$ruby_version

WORKDIR /usr/src/app

COPY . .
RUN bundle install

CMD ["bundle", "exec", "rake"]
