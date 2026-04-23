#!/bin/bash
set -e

echo "🚀 Préparation de l'environnement Wazuh..."

# 1. Création des répertoires nécessaires
mkdir -p certs config falco suricata/rules

# 2. Fichier de configuration des certificats
cat > ./config/certs.yml <<EOF
nodes:
  indexer:
    - name: wazuh-indexer
      ip: 127.0.0.1
  manager:
    - name: wazuh-manager
      ip: 127.0.0.1

  dashboard:
    - name: wazuh-dashboard
      ip: 127.0.0.1

EOF

# 3. Build de l'image locale depuis le Dockerfile du ZIP
echo "🔨 Build de l'image wazuh-certs-creator en local..."
docker build -t wazuh-certs-creator:local \
  ./indexer-certs-creator/

# 4. Génération des certificats via l'image buildée
rm -rf ./certs/*
echo "🔐 Génération des certificats..."
docker run --rm \
  -e CERT_TOOL_VERSION=4.7 \
  -v $(pwd)/config/certs.yml:/config/certs.yml \
  -v $(pwd)/certs:/certificates \
  wazuh-certs-creator:local

# 5. Ajuster les permissions
chmod -R 755 certs/
echo "✅ Certificats générés dans ./certs/"
ls -la certs/

# 6. Lancement de la stack
echo "🐳 Lancement de la stack de sécurité..."
docker-compose -f docker-compose.security.yml up -d

echo ""
echo "🎉 Terminé ! Dashboard : https://localhost:5601"