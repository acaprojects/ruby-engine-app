FROM ruby:2.4-alpine3.6

COPY entrypoint.sh /entrypoint.sh

# Workaround for https://github.com/moby/moby/issues/15858
WORKDIR /home/aca-apps/ruby-engine-app
COPY .gitignore Gemfile README.md Rakefile config.ru gems.txt ./
COPY .git ./.git/
COPY app/ ./app/
COPY bin/ ./bin/
COPY config/ ./config/
COPY db/ ./db/
COPY lib/ ./lib/
COPY log/ ./log/
COPY public/ ./public/
COPY test/ ./test/
COPY tmp/ ./tmp/
     
RUN ls -alR /home/aca-apps/ruby-engine-app && \
    adduser -D aca-apps && \
    chmod a+x /entrypoint.sh && \
    chown -R aca-apps:aca-apps /home/aca-apps && \
    apk update && \
    apk add bash tzdata curl nano git openssh   g++ make python  cmake perl libev-dev libuv-dev && \
    cp /usr/share/zoneinfo/Australia/Sydney /etc/localtime && \
    echo "Australia/Sydney" >  /etc/timezone

RUN gem install libcouchbase bundler rails && \ 
    chmod -R 777 $BUNDLE_PATH

USER aca-apps
WORKDIR /home/aca-apps


RUN git clone --depth=1 --single-branch -b couchbase-orm https://github.com/QuayPay/coauth.git /home/aca-apps/coauth && \
    git clone --depth=1 https://github.com/acaprojects/ruby-engine.git && \
    git clone --depth=1 https://github.com/acaprojects/aca-device-modules.git && \
    git clone --depth=1 https://github.com/aca-labs/omniauth-jwt

WORKDIR /home/aca-apps/ruby-engine-app
RUN bundle update 

USER root
RUN apk del cmake && \
    rm -rf /var/cache/apk/*

RUN echo "=====================================================" && \
    cat Gemfile.lock

USER aca-apps
ENV RAILS_ENV=production DISABLE_SPRING=1
ENTRYPOINT ["/entrypoint.sh"]
CMD ["engine"]
