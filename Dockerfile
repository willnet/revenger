FROM ruby:2.6.10
ARG BUNDLER_VERSION
ENV LANG C.UTF-8

# Install Node.js and npm
RUN apt-get update -qq && \
    apt-get install -y curl gnupg && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs xvfb ca-certificates unzip build-essential vim chromium chromium-driver sqlite3

# Install Yarn using npm instead of apt
RUN npm install -g yarn@1.21.1

# Install Japanese fonts
RUN curl -o /tmp/noto.zip https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip && \
    mkdir -p /usr/share/fonts/noto && \
    unzip /tmp/noto.zip -d /usr/share/fonts/noto/ && \
    fc-cache -v && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && truncate -s 0 /var/log/*log

WORKDIR /build
# Use a specific version of RubyGems compatible with Ruby 2.6.10
RUN gem update --system 3.0.9 &&\
    gem install -v $BUNDLER_VERSION bundler
WORKDIR /revenger
COPY . /revenger
RUN mkdir -p tmp/sockets
ENV DISPLAY :99
RUN printf '#!/bin/sh\nXvfb :99 -screen 0 1280x1024x24 &\nexec "$@"\n' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
