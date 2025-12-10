# Installation Docker dans Vagrant (Ubuntu)

## Étape 1 : Démarrer la machine virtuelle

```bash
# Aller dans le répertoire de votre machine virtuelle
cd /chemin/vers/votre/vagrant

# Démarrer la machine virtuelle
vagrant up

# Se connecter à la machine virtuelle
vagrant ssh
```

## Étape 2 : Installer Docker

Une fois connecté à la machine Vagrant, exécutez les commandes suivantes :

```bash
# 1. Installer les prérequis
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 2. Créer le répertoire pour la clé GPG Docker
sudo install -m 0755 -d /etc/apt/keyrings

# 3. Télécharger et installer la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Ajouter le dépôt Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Mettre à jour la liste des paquets
sudo apt-get update

# 6. Installer Docker Engine, CLI, containerd, buildx et compose
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Étape 3 : Démarrer et activer Docker

```bash
# Démarrer le service Docker
sudo systemctl start docker

# Activer Docker au démarrage
sudo systemctl enable docker

# Vérifier le statut de Docker
sudo systemctl status docker
# (Appuyez sur CTRL+C pour sortir)
```

## Étape 4 : Configurer les permissions (optionnel mais recommandé)

Pour permettre à l'utilisateur `vagrant` d'utiliser Docker sans `sudo` :

```bash
# Ajouter l'utilisateur vagrant au groupe docker
sudo usermod -aG docker vagrant

# OU donner les permissions directement au socket Docker
sudo chmod 666 /var/run/docker.sock
```

**Note :** Si vous utilisez `usermod`, vous devrez vous déconnecter et reconnecter pour que les changements prennent effet.

## Étape 5 : Vérifier l'installation

```bash
# Vérifier la version de Docker
docker --version

# Vérifier que Docker fonctionne
docker run hello-world
```

Si tout fonctionne, vous devriez voir le message "Hello from Docker!" qui confirme que :
1. Le client Docker a contacté le daemon Docker
2. Le daemon Docker a téléchargé l'image "hello-world" depuis Docker Hub
3. Le daemon Docker a créé un conteneur à partir de cette image
4. Le conteneur a exécuté et affiché le message

## Commandes Docker utiles

```bash
# Lister les images Docker
docker images

# Lister les conteneurs (actifs)
docker ps

# Lister tous les conteneurs (y compris arrêtés)
docker ps -a

# Construire une image depuis un Dockerfile
docker build -t nom-image:tag .

# Exécuter un conteneur
docker run nom-image

# Exécuter un conteneur en arrière-plan
docker run -d nom-image

# Accéder à un conteneur en cours d'exécution
docker exec -it ID_CONTAINER /bin/sh

# Arrêter un conteneur
docker stop ID_CONTAINER

# Supprimer un conteneur
docker rm ID_CONTAINER

# Supprimer une image
docker rmi nom-image

# Se connecter à Docker Hub
docker login

# Push une image vers Docker Hub
docker push nom-utilisateur/nom-image:tag
```

## Dépannage

Si vous avez des problèmes de permissions :
```bash
# Vérifier les permissions du socket Docker
ls -l /var/run/docker.sock

# Si nécessaire, corriger les permissions
sudo chmod 666 /var/run/docker.sock
```

Si Docker ne démarre pas :
```bash
# Vérifier les logs
sudo journalctl -u docker.service

# Redémarrer Docker
sudo systemctl restart docker
```

