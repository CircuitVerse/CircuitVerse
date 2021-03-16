FROM gitpod/workspace-postgres

USER root

# Install custom tools, runtime, etc. using apt-get
# For example, the command below would install "bastet" - a command line tetris clone:
#

RUN apt-get update \
    && apt-get install -y redis zlib1g-dev libssl-dev libreadline-dev libyaml-dev  libxml2-dev libxslt1-dev libcurl4-openssl-dev ruby-dev  \
    && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

#
# More information: https://www.gitpod.io/docs/42_config_docker/
