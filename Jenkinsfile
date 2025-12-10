pipeline {
    agent any

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
                sh './mvnw -B clean verify'
            }
        }
    }

    post {
        always {
            script {
                try {
                    junit 'target/surefire-reports/*.xml'
                } catch (Exception e) {
                    echo "Aucun rapport de test trouvé: ${e.message}"
                }
            }
            script {
                try {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                } catch (Exception e) {
                    echo "Aucun JAR trouvé: ${e.message}"
                }
            }
        }
    }
}

