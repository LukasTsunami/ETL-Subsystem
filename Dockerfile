# Etapa para instalar oh-my-zsh e plugins
FROM ruby:3.2.0-alpine AS zsh-base

RUN apk add --no-cache \
  zsh \
  curl \
  git \
  bash \
  less \
  tzdata \
  && adduser -D app

USER app
WORKDIR /home/app

# Instala oh-my-zsh com tema bira e plugins selecionados
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="bira"/' ~/.zshrc && \
    sed -i 's/plugins=(git)/plugins=(git rails ruby rake bundler history)/' ~/.zshrc && \
    echo 'export PATH="$HOME/.gem/ruby/3.3.0/bin:$PATH"' >> ~/.zshrc

# Faz cache disso para evitar reinstalar sempre
ENV ZSH_CONFIG_READY=1

# Volta para root para copiar configs mais tarde
USER root

# ---

# Etapa principal da aplicação
FROM ruby:3.2.0-alpine

ENV HOME_APP=/home/app
ENV BUNDLE_PATH=${HOME_APP}/vendor/gems
ENV RAILS_ENV=development
ENV RUBY_YJIT_ENABLE=1
ENV LD_PRELOAD=/usr/lib/libjemalloc.so.2

# Dependências do sistema
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
  less \
  curl

# Criação de usuário
RUN adduser -D app
WORKDIR ${HOME_APP}
USER app

# Copia o ambiente zsh da etapa anterior
COPY --from=zsh-base /home/app/.zshrc /home/app/.zshrc
COPY --from=zsh-base /home/app/.oh-my-zsh /home/app/.oh-my-zsh

# Gems
COPY --chown=app:app Gemfile Gemfile.lock ./
RUN bundle config set path "$BUNDLE_PATH" && \
    bundle config set --local without 'production' && \
    bundle install --retry 5 && \
    bundle clean

# App
COPY --chown=app:app . .

EXPOSE 3000

# Use zsh como shell interativo por padrão
CMD ["zsh"]
