FROM nginx:1.27-alpine AS runtime

# Remplacer la config globale (contient pid, events, http)
COPY nginx.conf /etc/nginx/nginx.conf

# Copier le vhost dans conf.d/
COPY vhost.conf /etc/nginx/conf.d/app.conf

# Copier les fichiers statiques
COPY index.html styles.css script.js /usr/share/nginx/html/

# Précréer les dossiers temp et donner les droits à nginx (uid 101)
RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp && \
    chown -R nginx:nginx /var/cache/nginx \
                         /var/log/nginx \
                         /var/run \
                         /usr/share/nginx/html && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

USER nginx
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:8080 || exit 1

CMD ["nginx", "-g", "daemon off;"]
