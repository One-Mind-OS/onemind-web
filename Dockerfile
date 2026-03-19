FROM node:22-slim AS base

# Install git (needed for update checker) and build essentials (needed for better-sqlite3)
RUN apt-get update && apt-get install -y git python3 make g++ && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
COPY scripts/postinstall.mjs ./scripts/postinstall.mjs
RUN npm install --frozen-lockfile 2>/dev/null \
    || npm install

# Copy source
COPY . .

# Build
RUN ONEMIND_BUILD_MODE=1 npm run build:ci

# Production
FROM node:22-slim AS runner

RUN apt-get update && apt-get install -y git curl unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=base /app/.next/standalone ./
COPY --from=base /app/.next/static ./.next/static
COPY --from=base /app/public ./public
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/package.json ./

# Data directory (mount as volume for persistence)
RUN mkdir -p /app/data && chown -R node:node /app

ENV NODE_ENV=production
ENV PORT=3456
ENV HOSTNAME=0.0.0.0

EXPOSE 3456
EXPOSE 3457

USER node

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD curl -f http://127.0.0.1:3456/ || exit 1

CMD ["node", "server.js"]
