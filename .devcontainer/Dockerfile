FROM ruby:3.2.1

# install dependencies
RUN apt-get update -qq \
 && apt-get install -y imagemagick shared-mime-info libvips \
 && apt-get install -y ca-certificates curl gnupg \
 && apt-get clean \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
 && apt-get update \
 && apt-get install nodejs -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/* \
 && apt-get update && apt-get -y install cmake && rm -rf /var/lib/apt/lists/* \
 && apt-get update && apt-get -y install netcat && rm -rf /var/lib/apt/lists/
