Django AWS EKS DevOps Platform

End-to-end DevOps implementation for a containerized Django application deployed on Amazon EKS using Docker, Terraform, Kubernetes, Helm, GitHub Actions, Amazon ECR, and Argo CD GitOps.

📌 Project Overview

This project demonstrates an end-to-end DevOps workflow for deploying a containerized Django REST application on AWS.

The infrastructure is provisioned using Terraform, the application is containerized using Docker, Kubernetes resources are packaged using Helm, container images are stored in Amazon ECR, and application deployment is managed using Argo CD following a GitOps approach.

The CI/CD pipeline is implemented using GitHub Actions with AWS OIDC authentication, avoiding the need to store long-lived AWS access keys in GitHub.

Main Objectives
Containerize a Django application using Docker.
Provision AWS infrastructure using Terraform.
Deploy the application to Amazon EKS.
Use Kubernetes for application orchestration.
Package Kubernetes resources using Helm.
Store Docker images in Amazon ECR.
Automate testing and validation using GitHub Actions.
Authenticate GitHub Actions with AWS using OIDC.
Implement GitOps deployment using Argo CD.
Use Amazon RDS PostgreSQL as the application database.
Use Amazon EFS for persistent application storage.
Expose the application through an AWS Application Load Balancer.


🏗️ Architecture
High-Level Architecture
                              Internet
                                  │
                                  ▼
                              Route 53
                                  │
                                  ▼
                       AWS Application Load Balancer
                                  │
                                  ▼
                       Kubernetes Ingress
                                  │
                                  ▼
                           Nginx Proxy
                                  │
                                  ▼
                           Django Service
                                  │
                     ┌────────────┴────────────┐
                     │                         │
                     ▼                         ▼
              PostgreSQL RDS                 EFS
              Application DB          Persistent Storage

              
## 🔄 CI/CD and GitOps Architecture

The project uses **GitHub Actions** for CI/CD and **Argo CD** for GitOps-based deployment to Amazon EKS.

### Workflow Overview

```text
Feature Branch
      │
      ▼
Pull Request
      │
      ▼
GitHub Actions Checks
      │
      ├── Django Unit Tests
      ├── Python Linting
      └── Terraform Validation
      │
      ▼
Merge to main / prod
      │
      ▼
Build & Push Docker Images
      │
      ▼
Amazon ECR
      │
      ▼
Update Helm Image Tags
      │
      ▼
Argo CD
      │
      ▼
Amazon EKS
```

### GitHub Actions Workflows

The CI/CD pipeline is organized into separate reusable workflows:

| Workflow                     | Purpose                                                               |
| ---------------------------- | --------------------------------------------------------------------- |
| `checks.yml`                 | Runs application and Terraform validation                             |
| `test-application.yml`       | Django tests and Python linting                                       |
| `test-terraform.yml`         | Terraform format and validation                                       |
| `deploy-terraform.yml`       | Provisions and updates AWS infrastructure using Terraform             |
| `build-push-update-helm.yml` | Builds Docker images, pushes them to ECR, and updates Helm image tags |
| `destroy.yml`                | Manually destroys Terraform-managed AWS infrastructure when required  |

### Branch Strategy

* **Feature branches** → Development and testing
* **`main`** → Staging/testing deployment path
* **`prod`** → Production deployment path

### GitOps with Argo CD

After the application image is built and pushed to **Amazon ECR**, the Helm configuration is updated with the new image tag.

**Argo CD monitors the Git repository and synchronizes the desired Kubernetes state with Amazon EKS.**

This provides a GitOps workflow where the Git repository acts as the source of truth for the Kubernetes application configuration.

### Deployment Flow

```text
Code Change
    ↓
Pull Request
    ↓
Automated Checks
    ↓
Merge
    ↓
Docker Build
    ↓
Amazon ECR
    ↓
Helm Values Update
    ↓
Argo CD Sync
    ↓
Amazon EKS
```

🛠️ Technology Stack
Category	Technology
Application	Django / Django REST Framework
Programming Language	Python
Containerization	Docker
Local Development	Docker Compose
Cloud	AWS
Kubernetes	Amazon EKS
Container Registry	Amazon ECR
Infrastructure as Code	Terraform
Kubernetes Packaging	Helm
CI/CD	GitHub Actions
GitOps	Argo CD
Database	Amazon RDS PostgreSQL
Persistent Storage	Amazon EFS
Load Balancing	AWS Application Load Balancer
DNS	Amazon Route 53
TLS	AWS Certificate Manager
AWS Authentication	GitHub Actions OIDC
Secrets Integration	Secrets Store CSI Driver
State Management	Amazon S3 + DynamoDB


☁️ AWS Infrastructure

Terraform is used to provision and manage the AWS infrastructure.

AWS Components
Amazon VPC

Provides network isolation for the application environment.

The VPC contains public and private networking components required by the EKS environment.

Amazon EKS

Amazon EKS provides the managed Kubernetes control plane used to run the Django application.

The workload runs on Kubernetes worker nodes in the configured AWS environment.

Amazon ECR

Amazon ECR stores the Docker images used by the Kubernetes workloads.

Two application images are maintained:

Django Application Image
        │
        ▼
Amazon ECR

Nginx Proxy Image
        │
        ▼
Amazon ECR
Amazon RDS PostgreSQL

RDS provides the PostgreSQL database used by the Django application.

Amazon EFS

Amazon EFS provides persistent/shared storage for application data such as static and media content.

AWS Application Load Balancer

The AWS Load Balancer Controller integrates Kubernetes Ingress with an AWS Application Load Balancer.

External HTTP/HTTPS traffic is routed toward the Kubernetes application.

Route 53

Route 53 provides DNS management for the application domain.

AWS Certificate Manager

ACM provides the TLS certificate used for HTTPS traffic.

IAM

IAM roles and policies control access between AWS services, Kubernetes workloads, and GitHub Actions.

S3 and DynamoDB

Terraform remote state uses:

Amazon S3 for Terraform state storage.
DynamoDB for Terraform state locking


🐳 Docker

The application is containerized using Docker.

☸️ Kubernetes

The application runs on Amazon EKS using Kubernetes resources.

⎈ Helm

The Kubernetes application is packaged using Helm.

Chart location:

helm/django-chart/

The Helm chart separates application configuration from Kubernetes templates.

Important configuration is maintained in:

helm/django-chart/values.yaml

🏗️ Terraform Infrastructure Architecture

The project follows an Infrastructure as Code (IaC) approach using Terraform to provision and manage AWS infrastructure.

The Terraform configuration is organized into two main areas:

infra/
├── setup/
│   ├── ecr.tf
│   ├── iam.tf
│   ├── github_aws_iam_openid_connect_provider.tf
│   └── ...
│
└── deploy/
    ├── 01_VPC_terraform-manifests/
    ├── 02_VPC_module_terraform-manifests/
    └── 03_EKS_terraform-manifests/
Terraform Setup

The infra/setup configuration contains the foundational resources required before application infrastructure deployment.

It manages resources such as:

Amazon ECR repositories
IAM roles and permissions
GitHub Actions OIDC integration
CI/CD related AWS configuration
Terraform Deployment

The infra/deploy directory contains the infrastructure required to run the application in AWS.

The deployment configuration is organized into separate Terraform projects for:

VPC and networking
EKS cluster and worker nodes
IAM roles and access
Amazon RDS PostgreSQL
Amazon EFS
AWS Load Balancer Controller
Secrets Store CSI integration
Argo CD
ACM and supporting resources
Security groups and networking rules

Dockerized Terraform

Terraform is executed through Docker Compose to maintain a consistent Terraform execution environment.

This provides:

Consistent Terraform versions
Reproducible execution environments
Similar Terraform environments locally and in CI/CD
Reduced dependency on local Terraform installation
Environment Management

Terraform workspaces are used to separate environment state.

Terraform
    │
    ├── staging
    │     └── AWS infrastructure
    │
    └── prod
          └── AWS infrastructure

This structure allows the same Terraform configuration to be used for multiple environments while maintaining separate Terraform state.


🔄 CI/CD with GitHub Actions

GitHub Actions automates application testing, Terraform validation, Docker image creation, image publishing, and Helm configuration updates.

🔐 GitHub Actions → AWS OIDC

The CI/CD pipeline uses GitHub Actions OIDC to authenticate with AWS.

📦 Amazon ECR

The CI/CD workflow authenticates with Amazon ECR and publishes the application images.

🚀 Argo CD / GitOps

Argo CD is used to implement GitOps-based Kubernetes deployment.

The Argo CD application definition is located at:

argocd/django-app.yaml

🔒 Security

Security considerations implemented in the project include:

GitHub → AWS OIDC

Avoids long-lived AWS credentials in GitHub Actions.

IAM

AWS permissions are provided through IAM roles and policies.

Kubernetes Service Accounts

Workloads use Kubernetes service accounts for controlled access to AWS resources.

Secrets Store CSI Driver

Kubernetes workloads can retrieve required secrets through the Secrets Store CSI integration rather than hardcoding credentials in application manifests.

Security Groups

AWS security groups control traffic between:

Internet
   │
   ▼
ALB
   │
   ▼
EKS
   │
   ▼
Application
🧪 Testing and Validation

The project includes automated application and Terraform validation.

Application
Django Tests
     +
Flake8
Terraform
Terraform Init
     +
Terraform Format Check
     +
Terraform Validate
Kubernetes

Application health can be validated using Kubernetes and AWS load balancer health checks.

Example troubleshooting commands:

kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get ingress

AWS target health can be investigated using the AWS CLI.

🛠️ Challenges and Troubleshooting

One of the major goals of this project was learning how to troubleshoot real DevOps deployment issues rather than only performing a successful deployment.

1. AWS ALB Target Health
Problem

The ALB target group reported unhealthy targets.

Investigation

The issue was investigated across multiple layers:

ALB
 │
 ▼
Target Group
 │
 ▼
Kubernetes Ingress
 │
 ▼
Service
 │
 ▼
Pod
 │
 ▼
Application Health Endpoint

The application health endpoint was tested directly and returned a successful HTTP response.

The investigation identified an AWS security group communication issue between the ALB and EKS workload networking.

Resolution

The required security group rule was configured to allow traffic from the ALB security group toward the application workload.

Lesson

Kubernetes application failures are not always caused by Kubernetes configuration. AWS networking, security groups, target groups, and health checks must also be considered.

2. GitHub Actions AWS Authentication
Problem

GitHub Actions required secure authentication to AWS.

Solution

GitHub Actions OIDC was configured with an AWS IAM trust relationship.

GitHub
   │
   ▼
OIDC Token
   │
   ▼
AWS IAM
   │
   ▼
Assumed Role
Lesson

OIDC provides a more secure CI/CD authentication model than storing long-lived AWS access keys.

3. Terraform State Management
Problem

Terraform behavior differed between local execution and CI/CD execution.

Investigation

Terraform state, workspace selection, backend configuration, and execution environments were compared.

Lesson

Terraform state is a critical part of Infrastructure as Code. The same configuration can produce different results when different state files, workspaces, or backends are being used.

📚 What I Learned

This project provided hands-on experience across the complete DevOps lifecycle.

AWS
VPC networking
Amazon EKS
Amazon ECR
IAM
Application Load Balancer
RDS PostgreSQL
EFS
Route 53
ACM
Docker
Dockerfile development
Containerized Django application
Nginx reverse proxy container
Docker Compose
Docker image versioning
Kubernetes
Deployments
Services
Ingress
ServiceAccounts
PersistentVolumeClaims
StorageClass
Health checks
Kubernetes troubleshooting
Terraform
Infrastructure as Code
Terraform modules
Remote state
State locking
Workspaces
Terraform validation
AWS resource provisioning
GitHub Actions
CI/CD workflows
Reusable workflows
Application testing
Terraform validation
Docker builds
ECR publishing
GitHub OIDC
Helm
Helm charts
Values files
Kubernetes templates
Application configuration
Image version management
GitOps
Argo CD
Declarative deployment
Git as the source of truth
Kubernetes synchronization
🔮 Future Improvements

Potential improvements include:

Add centralized monitoring with Prometheus and Grafana.
Add centralized logging.
Add application performance monitoring.
Add automated security scanning for Docker images.
Add Terraform security scanning.
Add Kubernetes manifest security scanning.
Add automated dependency vulnerability scanning.
Implement more complete environment promotion workflows.
Improve deployment rollback automation.
Add automated smoke tests after deployment.
Add disaster recovery documentation.
