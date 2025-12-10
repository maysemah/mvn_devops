# Résolution du problème "Could not resolve host: github.com"

## Diagnostic

Le serveur Jenkins ne peut pas résoudre le nom de domaine `github.com`. Voici comment diagnostiquer et résoudre le problème.

## Étape 1 : Vérifier la connectivité depuis le serveur Jenkins

Connectez-vous au serveur Jenkins et testez :

```bash
# Vérifier la résolution DNS
nslookup github.com

# Tester la connectivité réseau
ping -c 3 github.com

# Tester HTTPS
curl -v https://github.com

# Tester Git
git ls-remote https://github.com/maysemah/mvn_devops.git
```

## Étape 2 : Vérifier la configuration DNS

```bash
# Vérifier le fichier /etc/resolv.conf
cat /etc/resolv.conf

# Devrait contenir quelque chose comme :
# nameserver 8.8.8.8
# nameserver 8.8.4.4
```

## Étape 3 : Solutions possibles

### Solution 1 : Ajouter des serveurs DNS publics

```bash
# Éditer le fichier resolv.conf
sudo nano /etc/resolv.conf

# Ajouter :
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
```

### Solution 2 : Vérifier les paramètres réseau de la VM

Si vous utilisez Vagrant, vérifiez le `Vagrantfile` :

```ruby
config.vm.network "private_network", ip: "192.168.33.10"
config.vm.provider "virtualbox" do |vb|
  vb.name = "jenkins-server"
end
```

### Solution 3 : Vérifier le proxy (si applicable)

Si vous êtes derrière un proxy :

```bash
# Configurer Git pour utiliser un proxy
git config --global http.proxy http://proxy.example.com:8080
git config --global https.proxy https://proxy.example.com:8080

# Ou pour Jenkins spécifiquement
export http_proxy=http://proxy.example.com:8080
export https_proxy=https://proxy.example.com:8080
```

### Solution 4 : Vérifier le firewall

```bash
# Vérifier si le firewall bloque les connexions
sudo ufw status
sudo iptables -L

# Autoriser les connexions sortantes HTTPS
sudo ufw allow out 443/tcp
sudo ufw allow out 80/tcp
```

## Étape 4 : Test depuis l'utilisateur Jenkins

```bash
# Se connecter en tant qu'utilisateur Jenkins
sudo -u jenkins -i

# Tester la connectivité
nslookup github.com
ping -c 2 github.com
git ls-remote https://github.com/maysemah/mvn_devops.git
```

## Étape 5 : Redémarrer les services réseau

```bash
# Redémarrer le service réseau
sudo systemctl restart networking

# Ou redémarrer la machine
sudo reboot
```

## Solution temporaire : Utiliser l'IP directement (non recommandé)

Si rien ne fonctionne, vous pouvez temporairement utiliser l'IP de GitHub :

```bash
# Trouver l'IP de GitHub
nslookup github.com

# Utiliser l'IP dans le Jenkinsfile (temporairement)
# git branch: 'master', url: 'https://140.82.121.4/maysemah/mvn_devops.git'
```

**Note :** Cette solution n'est pas recommandée car l'IP peut changer.

## Vérification finale

Après avoir appliqué les corrections :

```bash
# Tester depuis le serveur Jenkins
nslookup github.com
ping -c 3 github.com
curl -I https://github.com
git ls-remote https://github.com/maysemah/mvn_devops.git
```

Si tous ces tests passent, le problème est résolu et Jenkins devrait pouvoir accéder à GitHub.

