# 🚀 CI/CD Pipeline with Jenkins, Docker, ArgoCD & EKS

This project demonstrates a **complete CI/CD workflow** for deploying a Python-based microservice using **Jenkins**, **Docker**, **ArgoCD**, and **Amazon EKS (Kubernetes)**.  

---
## 📌 Project Overview

Whenever changes are made to the Python application in the **source code GitHub repository**, a Jenkins pipeline is triggered to:

1. **Build** a Docker image using the updated source code.
2. **Tag** the image using the Jenkins `BUILD_NUMBER`.
3. **Push** the image to DockerHub.
4. **Trigger** another Jenkins job (`updatemanifest`) that:
   - Updates the Kubernetes `deployment.yaml` manifest with the new image.
   - Pushes the updated manifest to a **Kubernetes manifests repository**.
5. **ArgoCD** monitors the Kubernetes manifests repository and automatically **synchronizes** the changes to deploy the latest version on **Amazon EKS**.

---
