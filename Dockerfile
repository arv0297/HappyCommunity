#Stage 1: Runner
FROM ruby:3.4.10-slim AS baserunner

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq5 \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

#Stage 2: Builder
FROM baserunner AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY package.json package-lock.json ./
RUN npm install

FROM baserunner
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app/node_modules /app/node_modules
COPY . .

EXPOSE 3000

CMD ["bin/dev"]