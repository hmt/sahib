FROM ruby:slim
MAINTAINER hmt <dev@hmt.im>

RUN apt-get update && apt-get install -y \
      libmariadb-client-lgpl-dev \
      libmariadbd-dev \
      libpq-dev \
      build-essential \
      git && \
    mkdir /app

ENV APP /app
ENV LANG C.UTF-8

WORKDIR $APP
CMD bin/bundle exec puma

ADD Gemfile* $APP/

ENV BUNDLE_GEMFILE=$APP/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle

RUN bundle install  --without development test

ADD . $APP
