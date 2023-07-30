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
# set up workdir
WORKDIR /circuitverse

# install dependencies
RUN apt-get update -qq && apt-get install -y imagemagick shared-mime-info libvips && apt-get clean

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash \
 && apt-get update && apt-get install -y nodejs && rm -rf /var/lib/apt/lists/* \
 && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update && apt-get -y install sudo yarn cmake netcat libnotify-dev git chromium-driver chromium && rm -rf /var/lib/apt/lists/*

# If OPERATING_SYSTEM is Linux, create non-root user
RUN if [ "$OPERATING_SYSTEM" == "linux" ]; then \
    # create non-root user with same uid:gid as host non-root user
    groupadd -g ${NON_ROOT_GROUP_ID} -r user && useradd -u ${NON_ROOT_USER_ID} -r -g ${NON_ROOT_GROUPNAME} ${NON_ROOT_USERNAME} \
    && chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /circuitverse \
    && chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /home/${NON_ROOT_USERNAME} \
    && chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /home/vendor \
    # Provide sudo permissions to non-root user
    && adduser ${NON_ROOT_USERNAME} sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers ;\
fi

# Switch to non-root user
USER ${NON_ROOT_USERNAME}