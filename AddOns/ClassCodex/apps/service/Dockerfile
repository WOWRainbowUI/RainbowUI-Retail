# Standalone image for the Class Codex service. Build context = this directory
# (apps/service). On Coolify: set Base Directory to apps/service and Dockerfile
# to ./Dockerfile. The service has no cross-workspace deps yet, so it builds in
# isolation; revisit if a shared package (e.g. @classcodex/schema) is extracted.
FROM node:20-slim

RUN corepack enable
WORKDIR /app

COPY package.json ./
RUN pnpm install

COPY . ./

ENV PORT=8080
EXPOSE 8080
CMD ["pnpm", "start"]
