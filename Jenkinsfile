@Library('my-shared-library@release/v1.1.0') _

pipeline {
    agent { label 'build-agent' }

    environment {
        DOCKER_HUB_USER = 'dilipwdocker'
        IMAGE_NAME = 'devsecops-app'
        IMAGE_TAG = "${BUILD_NUMBER}"
        SONAR_SERVER = 'SonarQube-Server'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('OWASP Dependency-Check Scan') {
            steps {
                echo 'Running OWASP Dependency Scan...'
                sh 'dependency-check --project "DevSecOps App" --scan . --format "HTML" --out "dependency-check-report.html"'
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                // vars/trivyScan.groovy
                // blocks only on critical CVEs
                trivyScan('.')
            }
        }

        stage('SonarQube Code Analysis & Quality Gate') {
            steps {
                // vars/sonarAnalysis.groovy
                // sonarscanner + waits for tailored quality gate
                sonarAnalysis(env.SONAR_SERVER)
            }
        }

        stage('Docker Build & Push') {
            steps {
                // vars/dockerbuildpush.groovy
                dockerBuildPush.groovy(env.IMAGE_NAME, env.IMAGE_TAG, env.DOCKER_HUB_USER)
            }
        }

        stage('Trivy Container Image Scan') {
            steps {
                // scans image for critical CVEs
                trivyScan("${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.IMAGE_TAG}")
            }
        }
    }
    
    post{
        always{
            cleanWs()
        }
        success{
            echo "Build #${BUILD_NUMBER} succeeded!"
        }
        failure{
            echo "Build #${BUILD_NUMBER} failed! Check logs"
        }
    }
}
