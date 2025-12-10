#!/bin/bash

# Script d'installation Docker pour Ubuntu (Vagrant)
# Ce script installe Docker et configure les permissions

set -e

echo "=========================================="
echo "Installation de Docker"
echo "=========================================="

# 1. Mettre à jour les paquets
echo "Mise à jour des paquets..."
sudo apt-get update

# 2. Installer les prérequis
echo "Installation des prérequis..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# 3. Créer le répertoire pour la clé GPG
echo "Configuration de la clé GPG Docker..."
sudo install -m 0755 -d /etc/apt/keyrings

# 4. Télécharger et installer la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 5. Ajouter le dépôt Docker
echo "Ajout du dépôt Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6. Mettre à jour la liste des paquets
echo "Mise à jour de la liste des paquets..."
sudo apt-get update

# 7. Installer Docker
echo "Installation de Docker Engine, CLI, containerd, buildx et compose..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 8. Démarrer et activer Docker
echo "Démarrage du service Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# 9. Configurer les permissions pour l'utilisateur vagrant
echo "Configuration des permissions Docker..."
sudo usermod -aG docker vagrant
sudo chmod 666 /var/run/docker.sock

# 10. Vérifier l'installation
echo "=========================================="
echo "Vérification de l'installation..."
echo "=========================================="
docker --version
sudo systemctl status docker --no-pager

echo ""
echo "=========================================="
echo "Installation terminée avec succès!"
echo "=========================================="
echo ""
echo "Pour tester Docker, exécutez:"
echo "  docker run hello-world"
echo ""
echo "Note: Si vous avez utilisé usermod, déconnectez-vous et reconnectez-vous"
echo "      pour que les permissions prennent effet."

