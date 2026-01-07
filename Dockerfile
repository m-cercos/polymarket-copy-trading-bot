# ---------- Builder ----------
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./

# install deps (incluye dev) + build
RUN npm install

# copia el código (necesario para build y/o postinstall)
COPY . .

# compila TypeScript si existe script build
RUN npm run build || true

# elimina devDependencies sin volver a ejecutar install
RUN npm prune --omit=dev

# ---------- Runtime ----------
FROM node:20-alpine
WORKDIR /app

RUN apk add --no-cache dumb-init

# copia lo necesario desde builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

CMD ["dumb-init", "node", "dist/index.js"]
