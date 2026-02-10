# Build local monorepo image
FROM node:20-alpine

# Install system dependencies and build tools
RUN apk update && \
    apk add --no-cache \
        libc6-compat \
        python3 \
        make \
        g++ \
        build-base \
        cairo-dev \
        pango-dev \
        chromium \
        curl && \
    npm install -g pnpm

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Increase memory for the build process
ENV NODE_OPTIONS=--max-old-space-size=8192

WORKDIR /usr/src/flowise

# Copy app source
COPY . .

# Install dependencies and build
RUN pnpm install && \
    pnpm build

# Give the node user ownership
RUN chown -R node:node .
USER node

# Heroku ignores EXPOSE, but it's good practice
EXPOSE 3000

# FIX: We use the '--' to pass the '-p' flag through pnpm to the actual server
CMD ["sh", "-c", "pnpm start -- -p $PORT"]