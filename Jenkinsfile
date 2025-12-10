pipeline {
    agent any

    options {
        // Garder des logs horodatés
        timestamps()
    }

    stages {
        stage('Checkout') {
            steps {
                // Cloner depuis GitHub (repo public)
                git branch: 'master', url: 'https://github.com/maysemah/mvn_devops.git'
            }
        }

        stage('Build & Test') {
            steps {
                // Build + tests
                sh './mvnw -B clean verify'
            }
        }
    }

    post {
        always {
            // Ne pas échouer si aucun rapport (par exemple pas de tests)
            junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
    }
}

