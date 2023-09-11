FROM ruby:3.2.1

# Args
ARG NON_ROOT_USER_ID
ARG NON_ROOT_GROUP_ID
ARG NON_ROOT_USERNAME
ARG NON_ROOT_GROUPNAME
ARG OPERATING_SYSTEM

# Check mandatory args
RUN test -n "$NON_ROOT_USER_ID"
RUN test -n "$NON_ROOT_GROUP_ID"
RUN test -n "$OPERATING_SYSTEM"
RUN test -n "$NON_ROOT_USERNAME"
RUN test -n "$NON_ROOT_GROUPNAME"

# Create app directory
RUN mkdir /circuitverse
# Create non-root user directory
RUN mkdir /home/${NON_ROOT_USERNAME}
# Create non-root vendor directory
RUN mkdir /home/vendor
RUN mkdir /home/vendor/bundle
# set up workdir
WORKDIR /circuitverse

# Set shell to bash
SHELL ["/bin/bash", "-c"]

# install dependencies
RUN apt-get update -qq && \
 apt-get install -y libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev imagemagick shared-mime-info libvips sudo make cmake netcat libnotify-dev git chromium-driver chromium --fix-missing && apt-get clean

# Setup nodejs and yarn
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/*
