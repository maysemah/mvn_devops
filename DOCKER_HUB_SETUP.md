# Configuration Docker Hub pour Jenkins

## Problème : `unauthorized: access token has insufficient scopes`

Cette erreur signifie que les credentials Docker Hub utilisés n'ont pas les permissions nécessaires pour pousser des images.

## Solution : Créer un Personal Access Token (PAT)

### Étape 1 : Créer un token sur Docker Hub

1. **Connectez-vous à Docker Hub** : https://hub.docker.com
2. **Allez dans les paramètres de sécurité** :
   - Cliquez sur votre nom d'utilisateur (en haut à droite)
   - Sélectionnez **"Account Settings"**
   - Allez dans l'onglet **"Security"**
3. **Créez un nouveau token** :
   - Cliquez sur **"New Access Token"**
   - Donnez un nom descriptif (ex: `jenkins-push-token`)
   - **IMPORTANT** : Sélectionnez les permissions **"Read, Write & Delete"**
   - Cliquez sur **"Generate"**
4. **Copiez le token** :
   - ⚠️ **ATTENTION** : Le token ne sera affiché qu'une seule fois !
   - Copiez-le immédiatement et sauvegardez-le dans un endroit sûr

### Étape 2 : Configurer les credentials dans Jenkins

1. **Dans Jenkins** :
   - Allez dans **"Manage Jenkins"** → **"Manage Credentials"**
   - Sélectionnez le domaine approprié (généralement `(global)`)
   - Cliquez sur **"Add Credentials"**

2. **Remplissez le formulaire** :
   - **Kind** : `Username with password`
   - **Scope** : `Global`
   - **Username** : Votre nom d'utilisateur Docker Hub (ex: `semahmay`)
   - **Password** : Le **Personal Access Token** que vous venez de créer (pas votre mot de passe Docker Hub !)
   - **ID** : `docker-hub-credentials` (doit correspondre à l'ID dans le Jenkinsfile)
   - **Description** : `Docker Hub credentials for pushing images`

3. **Sauvegardez** les credentials

### Étape 3 : Vérifier que le repository existe

Assurez-vous que le repository `student-management` existe sur Docker Hub :

1. Allez sur https://hub.docker.com/repositories
2. Si le repository n'existe pas, créez-le :
   - Cliquez sur **"Create Repository"**
   - Nom : `student-management`
   - Visibilité : `Public` ou `Private` (selon vos préférences)
   - Cliquez sur **"Create"**

### Étape 4 : Tester le push

1. **Dans Jenkins**, relancez le build
2. **Activez le paramètre** `PUSH_TO_DOCKERHUB` à `true`
3. Le push devrait maintenant fonctionner !

## Alternative : Push manuel

Si vous préférez pousser manuellement depuis le serveur Jenkins :

```bash
# Se connecter au serveur Jenkins
ssh user@jenkins-server

# Se connecter à Docker Hub
docker login -u semahmay
# Entrez votre Personal Access Token quand demandé

# Pousser l'image
docker push semahmay/student-management:test
docker push semahmay/student-management:latest
```

## Dépannage

### Erreur : "unauthorized: authentication required"
- Vérifiez que vous utilisez un **Personal Access Token** et non votre mot de passe Docker Hub
- Vérifiez que le token a les permissions **"Read, Write & Delete"**

### Erreur : "repository does not exist"
- Créez le repository `student-management` sur Docker Hub
- Vérifiez que le nom d'utilisateur dans les credentials correspond au propriétaire du repository

### Erreur : "access token has insufficient scopes"
- Le token n'a pas les bonnes permissions
- Créez un nouveau token avec les permissions **"Read, Write & Delete"**
- Mettez à jour les credentials Jenkins avec le nouveau token

## Notes importantes

- ⚠️ **Ne partagez jamais votre Personal Access Token**
- 🔄 Les tokens peuvent être révoqués à tout moment depuis Docker Hub
- 📝 Si vous perdez un token, vous devez en créer un nouveau
- 🔒 Les tokens avec permissions "Write" peuvent pousser et supprimer des images

