# ========================
# STAGE 1 — Dependencies
# ========================
FROM node:18-alpine AS deps
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

# ========================
# STAGE 2 — Builder (TS + Prisma)
# ========================
FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma
COPY src ./src

# Copia as dependências instaladas anteriormente
COPY --from=deps /app/node_modules ./node_modules

# Gera artefatos do Prisma
RUN npx prisma generate

# Compila TypeScript (gera pasta dist/)
RUN npm run build

# ========================
# STAGE 3 — Runtime
# ========================
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3001

# Copia somente o necessário para rodar
COPY package*.json ./
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

EXPOSE 3001

CMD ["node", "dist/server.js"]
