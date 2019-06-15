FROM ruby:2.6.3-stretch

ARG LOCAL_BUILD

ENV BUNDLE_JOBS=4 RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true BUNDLE_PATH=/vendor/bundle LANG=C.UTF-8 LC_ALL=C.UTF-8 HOME=/home/app SHELL=/bin/bash

COPY --from=node:12.3.1-stretch /usr/local /usr/local
COPY --from=node:12.3.1-stretch /opt /opt

RUN \
  echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  apt-get update && \
  apt-get install --no-install-recommends -y less postgresql-client-10 zsh && \
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

RUN useradd --create-home --user-group --uid 1000 app
RUN mkdir -p /app /original $BUNDLE_PATH
RUN chown -R app /app /original /vendor

WORKDIR /app

USER app

COPY --chown=app Gemfile Gemfile.lock ./

RUN if [ -z "$LOCAL_BUILD" ]; then \
  bundle install --without development test\
  ;fi

COPY --chown=app package.json yarn.lock ./

RUN if [ -z "$LOCAL_BUILD" ]; then \
  yarn install \
  ;fi

COPY --chown=app . ./

RUN if [ -z "$LOCAL_BUILD" ]; then \
  export RAILS_ENV=production && \
  SECRET_KEY_BASE=`bin/rails secret` bin/rails assets:precompile \
  ;fi

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
