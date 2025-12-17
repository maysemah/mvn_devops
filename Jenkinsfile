pipeline {
    agent any

    parameters {
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip les tests pour un build plus rapide')
        string(name: 'DOCKER_USERNAME', defaultValue: 'semahmay', description: 'Nom d\'utilisateur Docker Hub')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Tag de l\'image Docker')
        booleanParam(name: 'PUSH_TO_DOCKERHUB', defaultValue: false, description: 'Push l\'image vers Docker Hub')
    }

    options {
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/maysemah/mvn_devops.git'
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    def skipTests = params.SKIP_TESTS ? '-DskipTests -Dmaven.test.skip=true' : ''
                    
                    sh """
                        chmod +x ./mvnw
                        export MAVEN_OPTS="-Xmx256m -Xms128m"
                        echo "Build démarré à \$(date)"
                        
                        # Build simplifié - compile puis package séparément pour éviter les timeouts
                        ./mvnw -B clean compile ${skipTests}
                        echo "Compilation terminée à \$(date)"
                        
                        ./mvnw -B package ${skipTests}
                        echo "Packaging terminé à \$(date)"
                        
                        ls -lh target/*.jar || echo "Pas de JAR trouvé"
                    """
                }
            }
        }
        
        stage('Build Docker Image') {
            when {
                expression {
                    def jarFiles = sh(script: 'find target -name "*.jar" -type f 2>/dev/null | head -1', returnStdout: true).trim()
                    return jarFiles != null && !jarFiles.isEmpty()
                }
            }
            steps {
                script {
                    def dockerUsername = params.DOCKER_USERNAME ?: 'student-management'
                    def imageName = "${dockerUsername}/student-management:${params.IMAGE_TAG}"
                    def imageNameLatest = "${dockerUsername}/student-management:latest"
                    
                    echo "Construction de l'image Docker: ${imageName}"
                    sh """
                        # Vérifier que le JAR existe
                        if [ ! -f target/*.jar ]; then
                            echo "ERREUR: Aucun JAR trouvé dans target/"
                            ls -la target/ || echo "Le répertoire target/ n'existe pas"
                            exit 1
                        fi
                        
                        # Afficher les JAR disponibles
                        echo "JAR trouvé:"
                        ls -lh target/*.jar
                        
                        # Télécharger l'image de base si nécessaire
                        docker pull eclipse-temurin:17-jdk-alpine || echo "Image déjà présente ou erreur réseau"
                        
                        # Construire l'image Docker
                        docker build -t ${imageName} .
                        docker tag ${imageName} ${imageNameLatest}
                        
                        # Afficher les images créées
                        docker images | grep student-management || true
                    """
                }
            }
        }
        
        stage('Push to Docker Hub') {
            when {
                allOf {
                    expression { params.PUSH_TO_DOCKERHUB == true }
                    expression { params.DOCKER_USERNAME != null && params.DOCKER_USERNAME != '' }
                }
            }
            steps {
                script {
                    def dockerUsername = params.DOCKER_USERNAME
                    def imageName = "${dockerUsername}/student-management:${params.IMAGE_TAG}"
                    def imageNameLatest = "${dockerUsername}/student-management:latest"
                    
                    echo "Push de l'image vers Docker Hub: ${imageName}"
                    
                    // Méthode 1: Utiliser les credentials Jenkins (recommandé)
                    try {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh """
                                echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                                docker push ${imageName} || {
                                    echo "ERREUR: Échec du push de ${imageName}"
                                    echo "Vérifiez que le token Docker Hub a les permissions 'write' et 'delete'"
                                    exit 1
                                }
                                docker push ${imageNameLatest} || {
                                    echo "ERREUR: Échec du push de ${imageNameLatest}"
                                    exit 1
                                }
                            """
                        }
                        echo "✅ Image poussée avec succès vers Docker Hub!"
                    } catch (Exception e) {
                        echo "⚠️  ERREUR lors du push vers Docker Hub: ${e.message}"
                        echo ""
                        echo "Solutions possibles:"
                        echo "1. Créez un Personal Access Token (PAT) sur Docker Hub:"
                        echo "   - Allez sur https://hub.docker.com/settings/security"
                        echo "   - Créez un nouveau token avec les permissions 'Read, Write & Delete'"
                        echo "   - Utilisez ce token comme mot de passe dans les credentials Jenkins"
                        echo ""
                        echo "2. Vérifiez que le repository '${dockerUsername}/student-management' existe sur Docker Hub"
                        echo ""
                        echo "3. L'image a été construite avec succès localement, vous pouvez la pousser manuellement:"
                        echo "   docker login -u ${dockerUsername}"
                        echo "   docker push ${imageName}"
                        echo "   docker push ${imageNameLatest}"
                        echo ""
                        // Ne pas faire échouer le build car l'image a été construite avec succès
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Build réussi!'
        }
        always {
            script {
                try {
                    def testFiles = sh(script: 'find target/surefire-reports -name "*.xml" 2>/dev/null | head -1', returnStdout: true).trim()
                    if (testFiles) {
                        junit 'target/surefire-reports/*.xml'
                    } else {
                        echo 'Aucun rapport de test trouvé - c\'est normal si les tests ont été skippés'
                    }
                } catch (Exception e) {
                    echo "Erreur lors de la recherche des rapports de test: ${e.message}"
                }
            }
            script {
                try {
                    def jarFiles = sh(script: 'find target -name "*.jar" -type f 2>/dev/null | head -1', returnStdout: true).trim()
                    if (jarFiles) {
                        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, allowEmptyArchive: true
                    } else {
                        echo 'Aucun JAR trouvé dans target/'
                    }
                } catch (Exception e) {
                    echo "Erreur lors de l'archivage: ${e.message}"
                }
            }
        }
    }
}
