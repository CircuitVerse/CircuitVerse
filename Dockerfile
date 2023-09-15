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

# If OPERATING_SYSTEM is Linux, create non-root user
RUN if [[ "$OPERATING_SYSTEM" == "linux" ]]; then \
    # Check if the uid or gid is not 0
    if [[ "$NON_ROOT_USER_ID" != "0" || "$NON_ROOT_GROUP_ID" != "0" ]]; then \
        # create non-root user with same uid:gid as host non-root user
        groupadd -g ${NON_ROOT_GROUP_ID} -r ${NON_ROOT_GROUPNAME} && useradd -u ${NON_ROOT_USER_ID} -r -g ${NON_ROOT_GROUPNAME} ${NON_ROOT_USERNAME} \
        && chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /circuitverse \
        && chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /home/${NON_ROOT_USERNAME} \
        && chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /home/vendor \
        && chown -R ${NON_ROOT_USERNAME}:${NON_ROOT_GROUPNAME} /home/vendor/bundle \
        # Provide sudo permissions to non-root user
        && adduser --disabled-password --gecos '' ${NON_ROOT_USERNAME} sudo \
        && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers ;\
    fi ; \
fi

# Switch to non-root user
USER ${NON_ROOT_USERNAME}