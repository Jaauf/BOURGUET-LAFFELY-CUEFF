# ── Stage 1 : installation des dépendances ──────────────────────────────────
FROM node:24-alpine AS deps
WORKDIR /app

# Copier uniquement les manifestes pour profiter du cache Docker
COPY package.json package-lock.json ./

# Installer uniquement les dépendances de production
RUN npm ci --omit=dev

# ── Stage 2 : image finale minimale ─────────────────────────────────────────
FROM node:24-alpine AS runtime
WORKDIR /app

# Créer un utilisateur non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copier les dépendances depuis le stage précédent
COPY --from=deps /app/node_modules ./node_modules

# Copier le code source
COPY server.js ./

# Droits sur le dossier de travail
RUN chown -R appuser:appgroup /app

# Basculer vers l'utilisateur non-root
USER appuser

# Exposer uniquement le port nécessaire
EXPOSE 3000

# Healthcheck intégré
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/healthcheck || exit 1

CMD ["node", "server.js"]
