ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION
ARG BUNDLER_VERSION
ARG NODE_MAJOR
ARG YARN_VERSION
ENV LANG C.UTF-8

RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends nodejs xvfb ca-certificates unzip build-essential default-mysql-client libappindicator1 fonts-liberation yarn=$YARN_VERSION-1 google-chrome-stable vim\
    && curl -o /tmp/noto.zip https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip \
    && mkdir /usr/share/fonts/noto \
    && unzip /tmp/noto.zip -d /usr/share/fonts/noto/ \
    && fc-cache -v \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && truncate -s 0 /var/log/*log


WORKDIR /build
RUN gem update --system &&\
    gem install -v $BUNDLER_VERSION bundler
WORKDIR /revenger
COPY . /revenger
RUN mkdir -p tmp/sockets
ENV DISPLAY :99
RUN printf '#!/bin/sh\nXvfb :99 -screen 0 1280x1024x24 &\nexec "$@"\n' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
