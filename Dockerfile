# ===========================
#   1) DEPENDENCIAS DE DESARROLLO
# ===========================
FROM node:19-alpine3.15 AS dev-deps
WORKDIR /app

# Copiamos los archivos necesarios para instalar dependencias
COPY package.json package-lock.json ./

# Instalación determinística (reproducible)
RUN npm ci


# ===========================
#   2) BUILDER
# ===========================
FROM node:19-alpine3.15 AS builder
WORKDIR /app

# Copiamos node_modules desde la etapa anterior
COPY --from=dev-deps /app/node_modules ./node_modules

# Copiamos el resto del proyecto
COPY . .

# Compile Typescript / Build de la app
RUN npm run build


# ===========================
#   3) DEPENDENCIAS DE PRODUCCIÓN
# ===========================
FROM node:19-alpine3.15 AS prod-deps
WORKDIR /app

COPY package.json package-lock.json ./

# Solo dependencias de producción
RUN npm ci --omit=dev


# ===========================
#   4) IMAGEN FINAL
# ===========================
FROM node:19-alpine3.15 AS prod
WORKDIR /app
EXPOSE 3000

# Si usas una variable de build
#ENV APP_VERSION=${APP_VERSION}

# Copy dependencias de producción
COPY --from=prod-deps /app/node_modules ./node_modules

# Copy dist generado por el builder
COPY --from=builder /app/dist ./dist

# Comando final
CMD ["node", "dist/main.js"]










