# Makefile — Raccourcis pour les opérations courantes
# Usage : make <cible>

.PHONY: help install deploy deploy-check \
        deploy-docker deploy-git deploy-traefik deploy-wazuh deploy-shuffle \
        deploy-security status clean-facts

# ── Cible par défaut ──────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "  ╔══════════════════════════════════════════════════════╗"
	@echo "  ║  BOURGUET-LAFFELY-CUEFF — Commandes Ansible         ║"
	@echo "  ╚══════════════════════════════════════════════════════╝"
	@echo ""
	@echo "  make install          Installer les collections Ansible Galaxy"
	@echo "  make deploy           Déploiement complet (demande sudo)"
	@echo "  make deploy-check     Dry-run (rien n'est modifié)"
	@echo ""
	@echo "  ── Déploiement par rôle ──────────────────────────────"
	@echo "  make deploy-docker    Installer Docker uniquement"
	@echo "  make deploy-git       Cloner/MAJ le dépôt uniquement"
	@echo "  make deploy-traefik   Déployer Traefik uniquement"
	@echo "  make deploy-wazuh     Déployer Wazuh uniquement"
	@echo "  make deploy-shuffle   Déployer Shuffle uniquement"
	@echo "  make deploy-security  Déployer la stack sécurité globale"
	@echo ""
	@echo "  make status           Afficher l'état des conteneurs"
	@echo "  make clean-facts      Vider le cache des facts Ansible"
	@echo ""

# ── Installation des dépendances Galaxy ──────────────────────────────────────
install:
	ansible-galaxy collection install -r requirements.yml

# ── Déploiements ──────────────────────────────────────────────────────────────
deploy:
	ansible-playbook site.yml --ask-become-pass

deploy-check:
	ansible-playbook site.yml --check --diff --ask-become-pass

deploy-docker:
	ansible-playbook site.yml --tags docker --ask-become-pass

deploy-git:
	ansible-playbook site.yml --tags git --ask-become-pass

deploy-traefik:
	ansible-playbook site.yml --tags traefik --ask-become-pass

deploy-wazuh:
	ansible-playbook site.yml --tags wazuh --ask-become-pass

deploy-shuffle:
	ansible-playbook site.yml --tags shuffle --ask-become-pass

deploy-security:
	ansible-playbook site.yml --tags security_stack --ask-become-pass

# ── Utilitaires ───────────────────────────────────────────────────────────────
status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null \
		|| echo "Docker non disponible"

clean-facts:
	rm -rf /tmp/ansible_facts_cache
	@echo "Cache facts supprimé."
