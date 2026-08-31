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

              
