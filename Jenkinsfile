@Library('my-shared-library@main') _

pipeline {
    agent {
        label 'ec2-agent'
    }
    
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
                    buildDocker(env.DOCKER_HUB_REPO, env.BUILD_NUMBER)
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    pushDocker(env.DOCKER_HUB_REPO, env.BUILD_NUMBER, 'docker-hub-creds')
                }
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
