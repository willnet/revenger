FROM ruby:2.6.3

# for npm install
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && \
    apt-get install -y mysql-client nodejs vim --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y vim build-essential patch libnss3 gconf2 libappindicator1 libasound2 libxss1 xdg-utils libgtk-3-0 libx11-xcb1 libxtst6 fonts-liberation lsb-release unzip libappindicator3-1 --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    curl -O https://chromedriver.storage.googleapis.com/2.36/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/chromedriver && \
    chmod +x /usr/local/bin/chromedriver && \
    curl -O "https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip" && \
    unzip NotoSansCJKjp-hinted.zip && \
    mkdir -p /usr/share/fonts/noto && \
    cp -p *.otf /usr/share/fonts/noto/ && \
    fc-cache -fv

ENV ENTRYKIT_VERSION 0.4.0

RUN wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

RUN mkdir -p /app
WORKDIR /app

RUN bundle config build.nokogiri --use-system-libraries

ENTRYPOINT [ \
  "prehook", "ruby -v", "--", \
  "prehook", "rm -f tmp/pids/server.pid", "--", \
  "prehook", "bundle install -j3 --quiet --path vendor/bundle", "--", \
  "prehook", "npm install -g bower", "--", \
  "prehook", "bower install --allow-root", "--", \
  "switch", \
    "shell=/bin/bash", \
    "console=bundle exec rails console", \
    "dbcreate=bundle exec rake db:create", \
    "bu=bundle update", "--" \
  ]
