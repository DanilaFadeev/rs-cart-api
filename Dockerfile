FROM node:14-alpine AS base
RUN apk add --no-cache tini && \
    npm set progress=false && npm config set depth 0
WORKDIR /app
ENTRYPOINT ["/sbin/tini", "--"]

# ==========
FROM base AS build
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# ==========
FROM base AS release
ENV NODE_ENV=production
ENV PORT=8080
COPY package*.json ./
RUN npm install --production
COPY --from=build /app/dist ./dist
USER node
EXPOSE 8080
CMD ["node", "dist/main"]
