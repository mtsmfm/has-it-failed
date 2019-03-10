FROM ruby:2.6.1-alpine

ARG LOCAL_BUILD

ENV BUNDLE_JOBS=4 RAILS_LOG_TO_STDOUT=true RAILS_SERVE_STATIC_FILES=true BUNDLE_PATH=/vendor/bundle LANG=C.UTF-8 LC_ALL=C.UTF-8

COPY --from=node:10.15.1-alpine /usr/local /usr/local
COPY --from=node:10.15.1-alpine /opt /opt

RUN apk update && apk add --no-cache build-base postgresql-dev tzdata less

RUN adduser -u 1000 -D app
RUN mkdir -p /app/tmp /vendor/bundle
RUN chown -R app /app /vendor

WORKDIR /app

USER app

COPY --chown=app Gemfile Gemfile.lock ./

RUN if [ -z "$LOCAL_BUILD" ]; then \
  bundle install \
  ;fi

COPY --chown=app package.json yarn.lock ./

RUN if [ -z "$LOCAL_BUILD" ]; then \
  yarn install \
  ;fi

COPY --chown=app . ./

RUN if [ -z "$LOCAL_BUILD" ]; then \
  SECRET_KEY_BASE=`bin/rails secret` RAILS_ENV=production bin/rails assets:precompile \
  ;fi

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
