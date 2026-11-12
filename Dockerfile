# =========================================
# Build dependencies
# =========================================
FROM node:26.13.1-alpine3.24 AS build-base

RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    pkgconf \
    cairo-dev \
    pango-dev \
    jpeg-dev \
    giflib-dev \
    librsvg-dev

WORKDIR /tmp/nginx/praeco

COPY package.json ./

# =========================================
# Dependencies
# =========================================
FROM build-base AS dependencies

RUN npm install --loglevel error

# =========================================
# Release
# =========================================
FROM node:26.13.1-alpine3.24 AS release

ENV NODE_OPTIONS=--openssl-legacy-provider

RUN apk add --no-cache \
    nginx \
    cairo \
    pango \
    libjpeg-turbo \
    giflib \
    librsvg && \
    mkdir -p /tmp/nginx/praeco \
             /var/log/nginx \
             /var/www/html

WORKDIR /tmp/nginx/praeco

COPY --from=dependencies /tmp/nginx/praeco/node_modules ./node_modules

COPY . .

RUN npm run build && \
    cp -r dist/. /var/www/html/ && \
    chown -R nginx:nginx /var/www/html

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]