FROM ruby:2-alpine
RUN apk update && \
    apk add alpine-sdk openssl-dev curl-dev pcre-dev && \
    gem install sinatra passenger --no-document && \
    passenger-config install-standalone-runtime --connect-timeout 120 --idle-timeout 120 && \
    passenger-config validate-install
COPY . /app
WORKDIR /app
ENTRYPOINT ["passenger", "start"]
