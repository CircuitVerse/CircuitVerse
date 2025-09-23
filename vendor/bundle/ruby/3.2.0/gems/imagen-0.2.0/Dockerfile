FROM ruby:2.4.1

# install Git 2.3
RUN echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu precise main" \
          >> /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/git-core/ppa/ubuntu precise main" \
          >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A1715D88E1DF1F24
RUN apt-get update && apt-get upgrade -y git

RUN mkdir /imagen

COPY Gemfile* /tmp/
WORKDIR /tmp

# use a local bundle path for gem inspections
ENV BUNDLE_PATH /imagen/.bundle

# add /bin to PATH
ENV BUNDLE_BIN=/imagen/.bundle/bin
ENV PATH $BUNDLE_BIN:$PATH

WORKDIR /imagen
ADD . /imagen
