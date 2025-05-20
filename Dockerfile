FROM ruby:3.4.4-alpine3.21 AS zsh-base

RUN apk add --no-cache \
  zsh \
  curl \
  git \
  bash \
  less \
  tzdata \
  yaml \
  yaml-dev \
  && adduser -D app

USER app
WORKDIR /home/app

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="bira"/' ~/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git rails ruby rake bundler history)/' ~/.zshrc && \
    echo 'export PATH="$HOME/.gem/ruby/3.4.0/bin:$PATH"' >> ~/.zshrc

USER root

FROM ruby:3.4.4-alpine3.21

ENV HOME_APP=/home/app
ENV BUNDLE_PATH=${HOME_APP}/vendor/gems
ENV PATH="${BUNDLE_PATH}/bin:${PATH}"
ENV RAILS_ENV=development
ENV RUBY_YJIT_ENABLE=1
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2

RUN apk add --no-cache \
  build-base \
  postgresql-dev \
  nodejs \
  yarn \
  git \
  tzdata \
  jemalloc \
  zsh \
  bash \
  yaml \
  yaml-dev \
  less \
  curl \
  && adduser -D app

WORKDIR ${HOME_APP}
USER app

COPY --from=zsh-base /home/app/.zshrc /home/app/.zshrc
COPY --from=zsh-base /home/app/.oh-my-zsh /home/app/.oh-my-zsh

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle config set path "$BUNDLE_PATH" && \
    bundle config set --local without 'production' && \
    bundle install --retry 5 && \
    bundle clean

COPY --chown=app:app . .

EXPOSE 3000
CMD ["zsh"]
