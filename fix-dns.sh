#!/bin/bash

# Script pour corriger le problème DNS sur le serveur Jenkins
# Ce script configure des serveurs DNS publics de manière permanente

set -e

echo "=========================================="
echo "Correction du problème DNS"
echo "=========================================="

# 1. Sauvegarder la configuration actuelle
echo "Sauvegarde de la configuration DNS actuelle..."
sudo cp /etc/resolv.conf /etc/resolv.conf.backup.$(date +%Y%m%d_%H%M%S)

# 2. Vérifier si systemd-resolved est utilisé
if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    echo "Configuration via systemd-resolved..."
    sudo mkdir -p /etc/systemd/resolved.conf.d
    sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf > /dev/null <<EOF
[Resolve]
DNS=8.8.8.8 8.8.4.4 1.1.1.1
FallbackDNS=1.1.1.1 1.0.0.1
EOF
    sudo systemctl restart systemd-resolved
    echo "systemd-resolved redémarré"
else
    # 3. Configuration directe de resolv.conf
    echo "Configuration directe de /etc/resolv.conf..."
    sudo tee /etc/resolv.conf > /dev/null <<EOF
# Configuration DNS pour Jenkins
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
EOF
    # Protéger le fichier contre les modifications automatiques
    sudo chattr +i /etc/resolv.conf 2>/dev/null || echo "Note: chattr non disponible, le fichier peut être modifié automatiquement"
fi

# 4. Tester la résolution DNS
echo ""
echo "Test de la résolution DNS..."
if nslookup github.com > /dev/null 2>&1; then
    echo "✅ DNS fonctionne correctement!"
    nslookup github.com | head -5
else
    echo "❌ DNS ne fonctionne toujours pas"
    echo "Vérifiez votre configuration réseau"
    exit 1
fi

# 5. Tester la connectivité
echo ""
echo "Test de connectivité vers GitHub..."
if ping -c 2 github.com > /dev/null 2>&1; then
    echo "✅ Connectivité réseau OK!"
else
    echo "⚠️  Ping échoué, mais cela peut être normal (firewall)"
fi

# 6. Tester Git
echo ""
echo "Test de Git vers GitHub..."
if git ls-remote https://github.com/maysemah/mvn_devops.git > /dev/null 2>&1; then
    echo "✅ Git peut accéder à GitHub!"
else
    echo "⚠️  Git ne peut pas accéder à GitHub"
    echo "Vérifiez: git ls-remote https://github.com/maysemah/mvn_devops.git"
fi

echo ""
echo "=========================================="
echo "Configuration terminée!"
echo "=========================================="
echo ""
echo "Pour tester depuis l'utilisateur Jenkins:"
echo "  sudo -u jenkins -i"
echo "  nslookup github.com"
echo "  git ls-remote https://github.com/maysemah/mvn_devops.git"



