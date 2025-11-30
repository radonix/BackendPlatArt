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
RUN npx prisma generate

# ====== STAGE 3: Runtime ======
FROM node:18-alpine
WORKDIR /app

# copia node_modules e código
COPY --from=build /app ./

ENV PORT=3000
EXPOSE 3000

CMD ["npm", "run", "start"]
