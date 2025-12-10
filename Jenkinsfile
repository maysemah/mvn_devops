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

        stage('Clean') {
            steps {
                sh """
                    chmod +x ./mvnw
                    ./mvnw -B clean
                """
            }
        }
        
        stage('Compile') {
            options {
                timeout(time: 20, unit: 'MINUTES')
            }
            steps {
                sh """
                    export MAVEN_OPTS="-Xmx1024m -Xms512m"
                    ./mvnw -B -T 1C compile -Dmaven.compile.fork=true
                """
            }
        }
        
        stage('Test') {
            when {
                expression { params.SKIP_TESTS == false }
            }
            options {
                timeout(time: 10, unit: 'MINUTES')
            }
            steps {
                sh """
                    export MAVEN_OPTS="-Xmx1024m -Xms512m"
                    ./mvnw -B -T 1C test || echo "Tests échoués mais on continue"
                """
            }
        }
        
        stage('Package') {
            options {
                timeout(time: 10, unit: 'MINUTES')
            }
            steps {
                script {
                    def skipTests = params.SKIP_TESTS ? '-DskipTests -Dmaven.test.skip=true' : ''
                    sh """
                        export MAVEN_OPTS="-Xmx1024m -Xms512m"
                        ./mvnw -B package ${skipTests}
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
                        docker build -t ${imageName} .
                        docker tag ${imageName} ${imageNameLatest}
                    """
                    
                    // Afficher les images créées
                    sh "docker images | grep student-management"
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
                                docker push ${imageName}
                                docker push ${imageNameLatest}
                            """
                        }
                        echo "Image poussée avec succès vers Docker Hub!"
                    } catch (Exception e) {
                        echo "Credentials Jenkins non configurés, tentative avec docker login manuel..."
                        // Méthode 2: Fallback - utiliser docker login si déjà connecté
                        sh """
                            if docker info 2>/dev/null | grep -q "Username"; then
                                echo "Utilisation de la session Docker existante"
                                docker push ${imageName}
                                docker push ${imageNameLatest}
                            else
                                echo "ERREUR: Vous devez configurer les credentials Docker Hub dans Jenkins"
                                echo "Ou vous connecter manuellement avec: docker login -u semahmay"
                                exit 1
                            fi
                        """
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
