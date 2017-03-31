FROM alpine:3.5

MAINTAINER Brandon Martel <brandonmartel@gmail.com>

ENV BUILD_PACKAGES="ruby-dev build-base imagemagick" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev sqlite-dev postgresql-dev mysql-dev" \
    RUBY_PACKAGES="ruby ruby-io-console ruby-json yaml nodejs" \
    YARN_PACKAGES="curl bash binutils tar" \
    RAILS_VERSION="5.1.0.rc1" \
    HOME=/home/nobody \
    PATH=/home/nobody/.yarn/bin:$PATH

RUN \
  mkdir -p /home/nobody/app && \
  touch /home/nobody/.bashrc && \
  chown -R nobody:nobody /home/nobody && \
  apk --update --upgrade add $BUILD_PACKAGES $RUBY_PACKAGES $DEV_PACKAGES $YARN_PACKAGES && \
  echo 'gem: --no-document' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc && \
  chown -R nobody:nobody /usr/lib/ruby && \
  chown nobody:nobody /usr/bin && \
  chown nobody:nobody /etc/gemrc

USER nobody
RUN \
  curl -o- -L https://yarnpkg.com/install.sh | bash && \
  gem install -N bundler && \
  gem install -N nokogiri -- --use-system-libraries && \
  gem install -N rails --version "$RAILS_VERSION" && \
  bundle config --global build.nokogiri  "--use-system-libraries" && \
  bundle config --global build.nokogumbo "--use-system-libraries"

# cleanup
USER root
RUN \
  find / -type f -iname \*.apk-new -delete && \
  rm -rf /var/cache/apk/* && \
  rm -rf /usr/lib/lib/ruby/gems/*/cache/* && \
  apk del $YARN_PACKAGES

WORKDIR /home/nobody/app

USER nobody

EXPOSE 3000
