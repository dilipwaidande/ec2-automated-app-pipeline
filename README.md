# AWS EC2 Automated DevSecOps CI/CD Pipeline

A Jenkins-based CI/CD pipeline that automates the flow from GitHub source code to a Docker container running on AWS EC2, with security and code-quality checks integrated into the pipeline.

## Architecture

GitHub → Webhook → Jenkins → Trivy → SonarQube → Quality Gate → Docker Build → Trivy Image Scan → Docker Hub → AWS EC2 Container

## Pipeline Flow

1. **GitHub Checkout**
   - Source code is pulled from the `main` branch.
   - GitHub Webhook triggers the Jenkins pipeline automatically.

2. **Trivy Filesystem Scan**
   - Scans the source directory for known vulnerabilities.

3. **SonarQube Analysis**
   - Performs static code analysis and code-quality checks.

4. **Quality Gate**
   - Pipeline waits for the SonarQube quality gate.
   - Pipeline is aborted if the quality gate fails.

5. **Docker Build**
   - Docker image is built using the Jenkins Shared Library.
   - Build number is used for image versioning.

6. **Trivy Image Scan**
   - Docker image is scanned for `HIGH` and `CRITICAL` vulnerabilities.

7. **Docker Hub Push**
   - Image is pushed to Docker Hub using Jenkins-managed credentials/token authentication.

8. **Container Deployment**
   - The Docker container is deployed on an AWS EC2 host.
   - Application port mapping: `8000 → 80`.

## Jenkins / DevOps Concepts Implemented

- GitHub Webhooks for automated pipeline triggering
- Jenkins Pipeline as Code
- Jenkins Shared Library using Groovy
- Jenkins agents/nodes and label-based execution
- Jenkins Credentials and token-based Docker authentication
- Jenkins RBAC for access control
- Trivy filesystem and container image security scanning
- SonarQube static code analysis
- SonarQube Quality Gates
- Docker image build, versioning and registry push
- AWS EC2 container deployment
- Jenkins build console output analysis for troubleshooting and error diagnosis

## Security

Credentials are not hard-coded in the Jenkinsfile. Docker authentication and other integrations are handled through Jenkins-managed credentials/configuration.

## Repository Structure

```text
.
├── Dockerfile
├── Jenkinsfile
├── index.html
└── README.md
