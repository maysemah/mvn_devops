# Configuration Docker Hub dans Jenkins

## Option 1 : Configuration des Credentials dans Jenkins (Recommandé - Sécurisé)

### Étape 1 : Créer les credentials dans Jenkins

1. **Aller dans Jenkins** → **Manage Jenkins** → **Credentials**
2. Cliquer sur **System** → **Global credentials (unrestricted)**
3. Cliquer sur **Add Credentials**
4. Remplir le formulaire :
   - **Kind** : `Username with password`
   - **Scope** : `Global`
   - **Username** : `semahmay`
   - **Password** : `dckr_pat_SuUulDX5n8t8GpG9FN_i2PCuiwg` (votre Personal Access Token)
   - **ID** : `docker-hub-credentials` (important : utiliser exactement ce nom)
   - **Description** : `Docker Hub credentials for semahmay`
5. Cliquer sur **OK**

### Étape 2 : Utiliser dans le pipeline

Le Jenkinsfile est déjà configuré pour utiliser ces credentials automatiquement quand vous cochez `PUSH_TO_DOCKERHUB`.

## Option 2 : Connexion manuelle sur le serveur Jenkins

Si vous préférez vous connecter manuellement sur le serveur Jenkins :

```bash
# Se connecter au serveur Jenkins (où Docker est installé)
ssh user@jenkins-server

# Se connecter à Docker Hub
docker login -u semahmay
# Entrer le token quand demandé: dckr_pat_SuUulDX5n8t8GpG9FN_i2PCuiwg

# Vérifier la connexion
docker info | grep Username
```

**Note :** Cette méthode nécessite que Docker soit installé sur le serveur Jenkins et que vous ayez accès SSH.

## Option 3 : Connexion depuis Vagrant (pour tests)

Pour tester depuis votre machine Vagrant :

```bash
# Dans Vagrant
docker login -u semahmay
# Entrer le token: dckr_pat_SuUulDX5n8t8GpG9FN_i2PCuiwg

# Tester le push
docker tag student-management:latest semahmay/student-management:latest
docker push semahmay/student-management:latest
```

## Utilisation dans le Pipeline Jenkins

Une fois configuré, dans Jenkins :

1. **Lancer un build** du pipeline
2. **Paramètres du build** :
   - `DOCKER_USERNAME` : `semahmay` (déjà pré-rempli)
   - `IMAGE_TAG` : `latest` (ou autre tag)
   - **Cocher** `PUSH_TO_DOCKERHUB` pour push vers Docker Hub
3. Le pipeline va automatiquement :
   - Construire l'image Docker
   - Se connecter à Docker Hub avec les credentials
   - Pousser l'image vers `semahmay/student-management:latest`

## Vérification

Après le push, vérifier sur Docker Hub :
- Aller sur https://hub.docker.com/r/semahmay/student-management
- Vous devriez voir votre image avec les tags `latest` et celui spécifié

## Sécurité

⚠️ **Important** : 
- Ne jamais commiter le token dans le code
- Utiliser les credentials Jenkins pour la sécurité
- Le token est stocké de manière sécurisée dans Jenkins

