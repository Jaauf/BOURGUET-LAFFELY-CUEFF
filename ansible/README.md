# 🛡️ BOURGUET-LAFFELY-CUEFF — Stack Sécurisée Ansible (v2)

Déploiement automatisé, modulaire et idempotent de la stack complète via Ansible **Roles**.

---

## 📁 Structure du projet

```
ansible-project/
├── site.yml                          ← Point d'entrée unique
├── ansible.cfg                       ← Configuration Ansible (inventory, callbacks…)
├── requirements.yml                  ← Collections Galaxy requises
├── Makefile                          ← Raccourcis make deploy, make status…
│
├── inventory/
│   └── hosts.ini                     ← Cible de déploiement (local ou distant)
│
├── group_vars/
│   └── all.yml                       ← TOUTES les variables centralisées ici
│
└── roles/
    ├── docker/                       ← Installation Docker Engine + Compose plugin
    │   ├── defaults/main.yml
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   └── meta/main.yml
    │
    ├── git/                          ← Clonage / mise à jour du dépôt
    │   ├── defaults/main.yml
    │   ├── tasks/main.yml
    │   └── meta/main.yml
    │
    ├── traefik/                      ← Reverse-proxy Traefik
    │   ├── defaults/main.yml
    │   ├── tasks/main.yml
    │   └── meta/main.yml
    │
    ├── wazuh/                        ← SIEM Wazuh (manager + dashboard)
    │   ├── defaults/main.yml
    │   ├── tasks/main.yml
    │   └── meta/main.yml
    │
    ├── shuffle/                      ← SOAR Shuffle
    │   ├── defaults/main.yml
    │   ├── tasks/main.yml
    │   └── meta/main.yml
    │
    └── security_stack/               ← Stack sécurité transverse
        ├── defaults/main.yml
        ├── tasks/main.yml
        └── meta/main.yml
```

---

## 🚀 Procédure — WSL Ubuntu vierge

### Étape 1 — Installer Ansible et pip

```bash
sudo apt update && sudo apt install -y python3 python3-pip git
pip3 install --user ansible
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc && source ~/.bashrc
ansible --version
```

### Étape 2 — Récupérer le projet Ansible

```bash
git clone https://github.com/Jaauf/BOURGUET-LAFFELY-CUEFF
cd BOURGUET-LAFFELY-CUEFF/ansible-project
```

### Étape 3 — Installer les collections Galaxy

```bash
# Via make (recommandé)
make install

# Ou directement
ansible-galaxy collection install -r requirements.yml
```

Cela installe :
- `community.docker` — modules `docker_compose_v2`, `docker_container_info`, `docker_network`
- `ansible.posix` — module `sysctl`

### Étape 4 — (Optionnel) Vérifier l'inventaire

```bash
# Pour un déploiement local (WSL), rien à changer — localhost est déjà configuré
cat inventory/hosts.ini

# Pour un déploiement distant, éditer :
# nano inventory/hosts.ini
```

### Étape 5 — Lancer le déploiement complet

```bash
# Via make
make deploy

# Ou directement
ansible-playbook site.yml --ask-become-pass
```

Ansible vous demande le mot de passe `sudo` une seule fois.

---

## ⚙️ Commandes utiles

| Commande | Action |
|---|---|
| `make deploy` | Déploiement complet |
| `make deploy-check` | Dry-run (rien n'est modifié) |
| `make deploy-docker` | Installer Docker uniquement |
| `make deploy-git` | Cloner/MAJ le repo uniquement |
| `make deploy-traefik` | Déployer Traefik uniquement |
| `make deploy-wazuh` | Déployer Wazuh uniquement |
| `make deploy-shuffle` | Déployer Shuffle uniquement |
| `make deploy-security` | Déployer la stack sécurité |
| `make status` | Afficher les conteneurs actifs |
| `make clean-facts` | Vider le cache des facts |

### Commandes Ansible avancées

```bash
# Déployer un seul rôle via tag
ansible-playbook site.yml --tags wazuh --ask-become-pass

# Déployer plusieurs rôles
ansible-playbook site.yml --tags "traefik,wazuh" --ask-become-pass

# Voir ce qui serait modifié (dry-run + diff)
ansible-playbook site.yml --check --diff --ask-become-pass

# Surcharger une variable à la volée
ansible-playbook site.yml -e "repo_branch=develop" --ask-become-pass

# Déploiement verbeux (debug)
ansible-playbook site.yml -v --ask-become-pass
```

---

## 🔧 Variables configurables

Toutes les variables se trouvent dans `group_vars/all.yml`.
Elles peuvent être surchargées par ordre de priorité :

```
group_vars/all.yml          ← valeurs par défaut du projet
host_vars/<hostname>.yml    ← surcharge par machine
-e "var=valeur"             ← surcharge en ligne de commande (priorité max)
```

| Variable | Défaut | Description |
|---|---|---|
| `project_dir` | `/opt/BOURGUET-LAFFELY-CUEFF` | Répertoire d'installation |
| `repo_url` | `https://github.com/…` | URL du dépôt Git |
| `repo_branch` | `main` | Branche à déployer |
| `docker_shared_network` | `proxy` | Réseau Docker partagé (Traefik) |
| `wazuh_compose_dir` | `…/security/wazuh` | Répertoire Compose Wazuh |
| `shuffle_compose_dir` | `…/security/shuffle` | Répertoire Compose Shuffle |
| `docker_healthcheck_retries` | `15` | Tentatives de vérification santé |
| `docker_healthcheck_delay` | `6` | Délai entre tentatives (s) |

---

## 🏗️ Principes DevOps appliqués

### Idempotence

Chaque tâche peut être rejouée sans effet de bord :

| Module utilisé | Idempotence garantie |
|---|---|
| `ansible.builtin.apt` | `state: present` — pas de réinstallation |
| `ansible.builtin.git` | Clone si absent, pull si en retard, no-change si à jour |
| `community.docker.docker_compose_v2` | Recrée uniquement les services dont la config a changé |
| `community.docker.docker_network` | `state: present` — ne recrée pas si existant |
| `ansible.posix.sysctl` | Écrit dans un fichier dédié, reload si changement |
| `ansible.builtin.get_url` | `force: false` — ne retélécharge pas si déjà présent |
| `ansible.builtin.apt_repository` | Idempotent par nature |

### Séparation des rôles

Un rôle = une technologie = une responsabilité unique :

```
docker        → Installe et configure Docker
git           → Gère le code source
traefik       → Reverse-proxy et routage
wazuh         → SIEM (collecte, analyse, alertes)
shuffle       → SOAR (orchestration des réponses)
security_stack → Services sécurité transverses
```

### Dépendances déclaratives (`meta/main.yml`)

```yaml
# Exemple : le rôle wazuh déclare qu'il a besoin de docker et git
dependencies:
  - role: docker
  - role: git
```

Ansible résout l'ordre d'exécution automatiquement.

### Tags granulaires

Chaque tâche et chaque rôle est taggué. Il est possible de cibler précisément :

```bash
ansible-playbook site.yml --tags wazuh          # Wazuh seulement
ansible-playbook site.yml --skip-tags wazuh     # Tout sauf Wazuh
ansible-playbook site.yml --tags prerequisites  # Docker seulement
```

---

## 🐳 Structure attendue du dépôt projet

```
BOURGUET-LAFFELY-CUEFF/
├── compose.yml                              ← Stack Traefik + app
└── security/
    ├── docker-compose.security.yml          ← Stack sécurité globale
    ├── wazuh/
    │   └── docker-compose.wazuh.yml
    └── shuffle/
        └── docker-compose.shuffle.yml
```

> Si la structure de votre repo diffère, adaptez les variables
> `wazuh_compose_dir`, `shuffle_compose_dir`, etc. dans `group_vars/all.yml`.

---

## 🔍 Dépannage

### `community.docker` non trouvée

```bash
ansible-galaxy collection install -r requirements.yml --force
```

### Docker ne démarre pas dans WSL2 (systemd absent)

```bash
sudo dockerd &
# ou activer systemd dans WSL2 :
echo -e '[boot]\nsystemd=true' | sudo tee /etc/wsl.conf
# Puis depuis PowerShell :  wsl --shutdown
```

### `permission denied` sur `/var/run/docker.sock`

```bash
sudo usermod -aG docker $USER && newgrp docker
```

### Wazuh ne démarre pas (vm.max_map_count)

Le rôle le configure automatiquement. Si le problème persiste :

```bash
sudo sysctl -w vm.max_map_count=262144
```

### Rejouer uniquement ce qui a échoué

```bash
# Ansible crée un fichier .retry désactivé par défaut (voir ansible.cfg)
# Utilisez plutôt les tags pour cibler le rôle en erreur :
ansible-playbook site.yml --tags wazuh -v --ask-become-pass
```

---

## 👥 Équipe — Master 2 Cybersécurité Ynov 2026

- BOURGUET
- LAFFELY
- CUEFF
