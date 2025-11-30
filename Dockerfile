# ====== STAGE 1: Dependencies ======
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

# ====== STAGE 2: Build (Prisma) ======
FROM node:18-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Gera os artefatos do Prisma
RUN npx prisma generate

# ====== STAGE 3: Runtime ======
FROM node:18-alpine
WORKDIR /app

# Copia node_modules e código (já com node_modules da etapa deps)
COPY --from=build /app ./

# Porta configurada via variável de ambiente
ENV PORT=3001

EXPOSE 3001

CMD ["npm", "run", "start"]
