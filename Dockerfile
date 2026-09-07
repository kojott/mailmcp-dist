# mailmcp 0.5.4 — prebuilt distribution, no build step
FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production PORT=8080
COPY package.json ./
COPY dist ./dist
USER node
EXPOSE 8080
HEALTHCHECK --interval=30s CMD wget -qO- http://127.0.0.1:8080/health || exit 1
CMD ["node", "dist/node.js"]
