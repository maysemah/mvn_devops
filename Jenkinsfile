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
                sh 'chmod +x ./mvnw && ./mvnw -B clean verify'
            }
        }
    }

    post {
        success {
            echo 'Build réussi!'
        }
        always {
            script {
                if (fileExists('target/surefire-reports')) {
                    junit 'target/surefire-reports/*.xml'
                } else {
                    echo 'Aucun rapport de test trouvé'
                }
            }
            script {
                if (fileExists('target/*.jar')) {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                } else {
                    echo 'Aucun JAR trouvé'
                }
            }
        }
    }
}
