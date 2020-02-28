FROM ruby:2.6.5


RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt update && \
    apt remove cmdtest && \
    apt install -y nodejs mysql-client build-essential patch libnss3 gconf2 libappindicator1 libasound2 libxss1 xdg-utils libgtk-3-0 libx11-xcb1 libxtst6 fonts-liberation lsb-release unzip libappindicator3-1 --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
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
RUN gem i bundler -v 1.17.3

ENTRYPOINT [ \
  "prehook", "ruby -v", "--", \
  "prehook", "rm -f tmp/pids/server.pid", "--", \
  "prehook", "bundle install -j3 --quiet --path vendor/bundle", "--", \
  "switch", \
    "shell=/bin/bash", \
    "console=bundle exec rails console", \
    "dbcreate=bundle exec rake db:create", \
    "bu=bundle update", "--" \
  ]
