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
