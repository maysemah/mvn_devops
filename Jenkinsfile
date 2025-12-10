pipeline {
    agent any

    parameters {
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip les tests pour un build plus rapide')
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
            options {
                timeout(time: 30, unit: 'MINUTES')
            }
            steps {
                script {
                    def skipTests = params.SKIP_TESTS ? '-DskipTests' : ''
                    sh """
                        chmod +x ./mvnw
                        # -B = batch mode (non-interactif, plus rapide)
                        # -T 1C = parallélise avec 1 thread par CPU core
                        # package = compile + test + package (plus rapide que verify)
                        ./mvnw -B -T 1C clean package ${skipTests}
                    """
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
