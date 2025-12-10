pipeline {
    agent any

    options {
        // Garder des logs horodatés
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                // Activer la couleur ANSI même si l’option globale n’est pas dispo
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
                    sh './mvnw -B clean verify'
                }
            }
        }
    }

    post {
        always {
            junit 'target/surefire-reports/*.xml'
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
    }
}

