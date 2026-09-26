@Library('my-shared-library@main') _

pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'dilipwdocker/project1-nginx'
        APP_NAME        = 'my-running-nginx-p4'
        SCANNER_HOME    = tool 'sonar-scanner'
    }

    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/dilipwaidande/ec2-automated-app-pipeline.git'
            }
        }

        stage('Trivy FileSystem Scan') {
            steps {
                sh "trivy fs --format table -o trivy
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh "${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectName=ec2-nginx-app -Dsonar.projectKey=ec2-nginx-app"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    buildDocker(env.DOCKER_HUB_REPO, env.BUILD_NUMBER)
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --severity HIGH,CRITICAL ${env.DOCKER_HUB_REPO}:${env.BUILD_NUMBER}"
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    pushDocker(env.DOCKER_HUB_REPO, env.BUILD_NUMBER, 'docker-hub-creds')
                }
            }
        }            

        stage('Container Deploy') {
            steps {
                script {
                    deployApp(env.APP_NAME, env.DOCKER_HUB_REPO, '8000', '80')
                }
            }
        }
    }

    post {
        always {
            sh "docker logout || true"
        }
        success {
            echo "DevSecOps Pipeline Executed Successfully!"
        }
        failure {
            echo "DevSecOps Pipeline Failed!"
        }
    }
}
