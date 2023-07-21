FROM ruby:3.2.1

# Args
ARG NON_ROOT_USER_ID
ARG NON_ROOT_GROUP_ID
ARG NON_ROOT_USERNAME=user
ARG NON_ROOT_GROUPNAME=user

# Create app directory
RUN mkdir /circuitverse
# Create non-root user directory
RUN mkdir /home/${NON_ROOT_USERNAME}
# set up workdir
WORKDIR /circuitverse

# install dependencies
RUN apt-get update -qq && apt-get install -y imagemagick shared-mime-info libvips && apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get install -y yarn && rm -rf /var/lib/apt/lists/* \
 && apt-get update && apt-get -y install cmake && rm -rf /var/lib/apt/lists/* \
 && apt-get update && apt-get -y install netcat && rm -rf /var/lib/apt/lists/*

# create non-root user with same uid:gid as host non-root user
RUN groupadd -g ${NON_ROOT_GROUP_ID} -r user && useradd -u ${NON_ROOT_USER_ID} -r -g ${NON_ROOT_GROUPNAME} ${NON_ROOT_USERNAME}
RUN chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /circuitverse
RUN chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /home/${NON_ROOT_USERNAME}
USER ${NON_ROOT_USERNAME}

# Set env variables
ENV NON_ROOT_USERNAME=${NON_ROOT_USERNAME}
ENV NON_ROOT_GROUPNAME=${NON_ROOT_GROUPNAME}