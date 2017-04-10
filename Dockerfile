FROM ruby:2.3.0

WORKDIR /usr/local/src/

ADD . /usr/local/src/
RUN cd /usr/local/src/
RUN gem install bundler
RUN bundle install

CMD bundle exec rspec -cfd spec/*
