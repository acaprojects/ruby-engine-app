FROM quay.io/acaprojects/ruby-alpine
LABEL version="1.0"

COPY entrypoint.sh /entrypoint.sh
RUN adduser -D aca-apps && \
    chmod a+x /entrypoint.sh && \
    apk update && \
    apk add bash tzdata curl nano git openssh   g++ make python  cmake perl libev-dev libuv-dev && \
    cp /usr/share/zoneinfo/Australia/Sydney /etc/localtime && \
    echo "Australia/Sydney" >  /etc/timezone

RUN gem install libcouchbase bundler rails && \ 
    chmod -R 777 $BUNDLE_PATH

USER aca-apps
WORKDIR /home/aca-apps

RUN git clone https://github.com/QuayPay/coauth.git /home/aca-apps/coauth && \
    git clone https://github.com/acaprojects/ruby-engine.git && \
    git clone https://github.com/acaprojects/aca-device-modules.git && \
    git clone https://github.com/acaprojects/ruby-engine-app.git

WORKDIR /home/aca-apps/coauth
RUN git checkout couchbase-orm

WORKDIR /home/aca-apps/ruby-engine-app
RUN bundle install 

USER root
RUN apk del make cmake python && \
    rm -rf /var/cache/apk/*

RUN echo "=====================================================" && \
    cat Gemfile.lock

USER aca-apps
ENV RAILS_ENV=production DISABLE_SPRING=1
ENTRYPOINT ["/entrypoint.sh"]
CMD ["engine"]
