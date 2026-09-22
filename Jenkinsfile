pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'dilipwdocker/project1-nginx'
        APP_NAME        = 'my-running-nginx-app'
    }

    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/dilipwaidande/ec2-automated-app-pipeline.git'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker Image..."
                    sh "docker build -t ${DOCKER_HUB_REPO}:${BUILD_NUMBER} -t ${DOCKER_HUB_REPO}:latest ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    echo "Pushing Image to Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_HUB_REPO}:latest"
                    }
                }
            }
        }

        stage('Container Deploy') {
            steps {
                script {
                    echo "Deploying Container on EC2..."
                    sh "docker stop ${APP_NAME} || true"
                    sh "docker rm ${APP_NAME} || true"
                    sh "docker run -d --name ${APP_NAME} -p 8000:80 ${DOCKER_HUB_REPO}:latest"
                }
            }
        }
    }

    post {
        always {
            sh "docker logout || true"
        }
        success {
            echo "Pipeline Executed Successfully!"
        }
        failure {
            echo "Pipeline Failed!"
        }
    }
}
