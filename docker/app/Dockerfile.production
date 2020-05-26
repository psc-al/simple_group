FROM ruby:2.7.1-alpine3.11 as Builder

ARG RAILS_ENV
ARG SMTP_SENDER_EMAIL
ARG SMTP_ADDRESS
ARG SMTP_USERNAME
ARG SMTP_PASSWORD
ARG APPLICATION_HOST
ARG SECRET_KEY_BASE

ADD Gemfile* /opt/rails/

WORKDIR /opt/rails/

RUN apk add --update --no-cache --virtual build-dependencies build-base \
	&& apk add --update --no-cache --virtual runtime-dependencies \
		postgresql-client \
		postgresql-dev \
		tzdata \
		yarn \
	&& bundle config set deployment 'true' \
	&& bundle config set without 'development test' \
	&& bundle install \
	&& apk del build-dependencies \
	&& rm -rf /opt/rails/vendor/bundle/ruby/*/cache/*.gem \
	&& find /opt/rails/vendor/bundle/ruby/*/gems/ -name "*.c" -delete \
	&& find /opt/rails/vendor/bundle/ruby/*/gems/ -name "*.o" -delete

COPY package.json yarn.lock /opt/rails/

RUN yarn install

ADD . /opt/rails

RUN bundle exec rake assets:precompile \
	&& rm -rf node_modules tmp/cache vendor/assets lib/assets \
	&& find ./app/assets -mindepth 1 -name config -prune -o -exec rm -rf {} +

FROM ruby:2.7.1-alpine3.11

RUN apk add --update --no-cache \
	postgresql-client \
	tzdata

COPY --from=Builder /usr/local/bundle /usr/local/bundle
COPY --from=Builder /opt/rails /opt/rails

WORKDIR /opt/rails

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-p", "3000", "-C", "./config/puma.rb"]
