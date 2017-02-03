FROM ruby:2.4.0

RUN mkdir /keep_up
WORKDIR /keep_up

# Set up minimum files to run bundler
ADD Gemfile /keep_up
ADD keep_up.gemspec /keep_up
RUN mkdir -p /keep_up/lib/keep_up
ADD lib/keep_up/version.rb /keep_up/lib/keep_up
ADD .git /keep_up

RUN bundle install

RUN gem uninstall bunder -xa
RUN gem install bundler --version=1.13.7
RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

ADD . /keep_up
RUN bundle exec rake
