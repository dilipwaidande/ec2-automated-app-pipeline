# Enterprise DevSecOps CI Pipeline with Jenkins Shared Library

[![Jenkins](https://img.shields.io/badge/Jenkins-2.401+-d33833?style=flat&logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![AWS EC2](https://img.shields.io/badge/AWS-EC2-FF9900?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/ec2/)
[![Docker](https://img.shields.io/badge/Docker-29.1.3-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.io/)
[![Trivy](https://img.shields.io/badge/Trivy-Vulnerability_Scanner-13a89e?style=flat&logo=aqua&logoColor=white)](https://github.com/aquasecurity/trivy)
[![SonarQube](https://img.shields.io/badge/SonarQube-Quality_Gate-4E9BCD?style=flat&logo=sonarqube&logoColor=white)](https://www.sonarqube.org/)

This repository contains the application and pipeline definition for **Enterprise DevSecOps CI Pipeline**. It demonstrates a production-grade, distributed Continuous Integration pipeline running on AWS EC2 instances, leveraging **Jenkins Shared Libraries**, a **Master-Agent (Distributed) Architecture over SSH**, and multi-layered automated security gates.

---

🔥 Key Security & Architectural Features
Distributed Master-Agent Architecture: Offloads all heavy build, compilation, and security analysis tasks from the Jenkins Controller to a dedicated SSH worker agent (build-agent), preventing Controller memory exhaustion and operational failure.
Jenkins Shared Library Modularization: Standardizes pipeline logic across enterprise applications using reusable Groovy scripts stored in an external repository (jenkins-shared-library@release/v1.1.0).
Automated SCA (Software Composition Analysis): Scans application dependencies using OWASP Dependency-Check to identify known CVEs in third-party libraries.
Trivy Hard-Stop Gates: Enforces a strict pipeline break (--exit-code 1) whenever CRITICAL vulnerabilities are detected in either source files or published container images.
SonarQube Static Analysis & Quality Gate Enforcement: Pauses pipeline execution using waitForQualityGate() to ensure code security, test coverage, and code hygiene standards are strictly met before artifact generation.
Zero-Trust Credential Handling: Uses Jenkins secret store and Groovy withCredentials blocks to handle Docker Hub registry authentication without exposing sensitive environment tokens in build logs.

🛠️ Tooling & Tech Stack
Domain
Technology
Configuration Details
Compute / Infra
AWS EC2
Controller Node + Dedicated Worker Agent Node (t3.medium+)
Orchestration
Jenkins
Master-Agent architecture via SSH key authentication
Shared Code
Jenkins Shared Library
Branch: release/v1.1.0
SCA Security
OWASP Dependency-Check
Version 8.4.0 CLI
FS & Image Security
Aqua Security Trivy
Version 0.71.2 (--severity HIGH,CRITICAL)
Code Quality / SAST
SonarQube Server & Scanner
Governed by custom Quality Gate
Containerization
Docker Engine
Version 29.1.3
Artifact Registry
Docker Hub
Encrypted authentication via Jenkins Store
📂 Repository Structure
.
├── Jenkinsfile                 # Main declarative pipeline script (imports Shared Library)
├── Dockerfile                  # Application containerization definition
├── index.html                  # Application frontend source
└── README.md                   # Project architecture and execution documentation

⚙️ Pipeline Stages Deep Dive
@Library('my-shared-library@release/v1.1.0') _
Checkout Code: Fetches the branch code from GitHub directly onto the worker agent node.
OWASP Dependency-Check Scan: Evaluates project dependencies and outputs an HTML vulnerability report (dependency-check-report.html).
Trivy Filesystem Scan: Invokes vars/trivyScan.groovy to perform a file-level security audit. Fails the build if CRITICAL flaws exist.
SonarQube Code Analysis & Quality Gate: Invokes vars/sonarAnalysis.groovy. Sends static analysis data to SonarQube and halts execution until the Quality Gate returns status OK.
Docker Build & Push: Invokes vars/dockerBuildPush.groovy. Builds the Docker image and pushes DOCKER_HUB_USER/devsecops-app:${BUILD_NUMBER} using stored credentials.
Trivy Container Image Scan: Performs a final security audit on the compiled image in Docker Hub before marking the build successful.
