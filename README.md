
# Enterprise DevSecOps CI Pipeline with Jenkins Shared Library

![Jenkins](https://img.shields.io/badge/Jenkins-2.401+-d33833?style=flat&logo=jenkins&logoColor=white)
![AWS EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=flat&logo=amazon-aws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-29.1.3-2496ED?style=flat&logo=docker&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-Security_Scanning-13a89e?style=flat&logo=aqua&logoColor=white)
![SonarQube](https://img.shields.io/badge/SonarQube-Quality_Gate-4E9BCD?style=flat&logo=sonarqube&logoColor=white)

## Overview

This project demonstrates a Jenkins CI pipeline built around a distributed architecture, with a Jenkins controller and a dedicated build agent running on separate AWS EC2 instances.

The pipeline automates the main steps involved in building and securing a containerized application. It checks out the source code, scans dependencies and files for vulnerabilities, runs SonarQube analysis, builds a Docker image, and pushes the image to Docker Hub.

Pipeline logic is organized into a Jenkins Shared Library so that common tasks can be reused across multiple projects.

The goal is to demonstrate how security checks can be integrated into a CI pipeline and used to prevent builds with serious vulnerabilities or failing quality gates from progressing.

## Architecture

The setup uses two EC2 instances:

- **Jenkins controller:** Manages pipeline execution, credentials, and agent connections.
- **Build agent (`build-agent`):** Runs the build, security scans, SonarQube scanner, and Docker commands.

The controller connects to the agent over SSH. Build and scanning workloads run on the agent rather than directly on the controller.

```text
                  AWS EC2
        +--------------------------+
        |    Jenkins Controller    |
        |                          |
        |  - Pipeline management   |
        |  - Credentials           |
        |  - Agent connection      |
        +------------+-------------+
                     |
                     | SSH
                     v
        +--------------------------+
        |      Build Agent         |
        |      Ubuntu 24.04         |
        |                          |
        |  1. Checkout source      |
        |  2. Dependency-Check     |
        |  3. Trivy FS scan        |
        |  4. SonarQube analysis   |
        |  5. Docker build & push  |
        |  6. Trivy image scan     |
        +------------+-------------+
                     |
                     v
        +--------------------------+
        |       Docker Hub         |
        |    Container Registry    |
        +--------------------------+
```

## What the pipeline does

### 1. Source checkout

The pipeline checks out the application source code from GitHub onto the build agent.

### 2. Dependency scanning

OWASP Dependency-Check scans project dependencies for known vulnerabilities and generates an HTML report.

### 3. Filesystem scanning

Trivy scans the source workspace for vulnerabilities in supported files and dependencies. The pipeline is configured to fail when the scan finds CRITICAL vulnerabilities.

### 4. SonarQube analysis

SonarQube analyzes the application for code-quality issues and security-related findings. The pipeline waits for the configured Quality Gate result before continuing.

### 5. Docker image build and push

The application is packaged into a Docker image and pushed to Docker Hub. The image tag uses the Jenkins build number to distinguish between builds.

### 6. Container image scanning

Trivy scans the built image for vulnerabilities. A failed scan prevents the pipeline from completing successfully.

## Jenkins Shared Library

The pipeline imports a shared library from a separate Git repository:

```groovy
@Library('my-shared-library@release/v1.1.0') _
```

The shared library keeps common pipeline tasks separate from the main `Jenkinsfile`. This makes the pipeline easier to maintain and allows the same scanning and build logic to be reused by other applications.

The library contains the following pipeline steps:

| Script | Purpose |
|---|---|
| `vars/trivyScan.groovy` | Runs the Trivy filesystem scan |
| `vars/sonarAnalysis.groovy` | Runs SonarQube analysis and handles the Quality Gate |
| `vars/dockerBuildPush.groovy` | Builds the Docker image and pushes it to Docker Hub |

## Tools and technologies

| Component | Technology | Purpose |
|---|---|---|
| Infrastructure | AWS EC2 | Hosts the Jenkins controller and build agent |
| CI/CD | Jenkins | Runs and manages the pipeline |
| Agent connection | SSH | Connects the controller to the build agent |
| Pipeline reuse | Jenkins Shared Library | Stores reusable pipeline logic |
| Dependency scanning | OWASP Dependency-Check 8.4.0 | Identifies known dependency vulnerabilities |
| Filesystem and image scanning | Trivy 0.71.2 | Checks files and container images for vulnerabilities |
| Code analysis | SonarQube | Analyzes code quality and security findings |
| Containerization | Docker Engine 29.1.3 | Builds the application image |
| Registry | Docker Hub | Stores the built image |

The versions listed above are the versions targeted by this project configuration, not a guarantee that every version combination is compatible with every environment.

## Repository structure

```text
.
├── Jenkinsfile
├── Dockerfile
├── index.html
└── README.md
```

The `Jenkinsfile` defines the pipeline stages, while the shared library contains the reusable Groovy scripts. The `Dockerfile` defines how the application is packaged into a container, and `index.html` contains the application frontend.

