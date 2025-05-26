# 🚀 CI/CD Pipeline with Jenkins, Docker, ArgoCD & Amazon EKS

This project showcases a **complete CI/CD workflow** to build, push, and deploy a Python-based microservice using **Jenkins**, **Docker**, **ArgoCD**, and **Amazon EKS (Kubernetes)**.

---

## 📌 Overview

When changes are pushed to the **GitHub repository**, a Jenkins pipeline is triggered to:

1. **Build** a Docker image using the latest source code.
2. **Tag** the image using the Jenkins `BUILD_NUMBER`.
3. **Push** the image to **Docker Hub**.
4. **Trigger** a secondary Jenkins job (`updatemanifest`) to:
   - Update the image tag in the Kubernetes `deployment.yaml`.
   - Push the updated manifest to a **Kubernetes manifests repository**.
5. **ArgoCD** detects changes in the manifest repository and automatically **synchronizes** them to **deploy the latest version** on **Amazon EKS**.

---

## 🗂️ Repository Structure

### 🔹 1. Application Repository  
📁 **GitHub:** `[Your GitHub Repo URL]`

```
vproject-source-code/
├── Dockerfile
├── Jenkinsfile
├── README.md
├── app.py
├── requirements.txt
└── templates/
    └── index.html
```

| File/Folder         | Description                                                         |
|---------------------|---------------------------------------------------------------------|
| `app.py`            | A simple **Flask** application that returns a "Hello" message.      |
| `requirements.txt`  | Python dependencies (e.g., Flask, render_template).                                  |
| `Dockerfile`        | Docker configuration for containerizing the app.                    |
| `Jenkinsfile`       | Jenkins pipeline for build, tag, push, and trigger manifest update. |
| `templates/index.html` | HTML template rendered by the Flask app.                         |
| `.gitignore`        | Git ignore file to exclude unnecessary files. *(Add if missing)*    |

### 🔹 2. Kubernetes Manifest Repository  
📁 **GitHub:** `[Your Kubernetes Manifest Repo URL]`

| File/Folder        | Description                                                                 |
|--------------------|-----------------------------------------------------------------------------|
| `deployment.yaml`  | Kubernetes Deployment manifest (auto-updated by Jenkins with image tag).    |
| `service.yaml`     | Kubernetes Service manifest to expose the application.                      |
| `Jenkinsfile`      | Jenkins pipeline to update image in `deployment.yaml` and commit changes.   |

---

## 🔗 GitHub → Jenkins Webhook Setup

### GitHub Setup

1. Go to **GitHub → Repository Settings → Webhooks**.
2. Click **Add Webhook**.
3. **Payload URL:**  
   ```sh
   http://[JENKINS_SERVER_IP]:8080/github-webhook/
   ```
4. **Content Type:**  
   ```sh
   application/json
   ```
5. **Trigger:**  
   Select **Just the push event**.
6. Click **Add Webhook**.

### Jenkins Setup

1. Open **Jenkins UI → Job Configuration**.
2. Under **Build Triggers**, select:  
   ```sh
   GitHub hook trigger for GITScm polling
   ```
3. Click **Save**.

---

## ⚙️ ArgoCD Installation & Configuration on Kubernetes

### Step 1: Create Namespace

```sh
kubectl create namespace argocd
```

### Step 2: Install ArgoCD

```sh
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Step 3: Verify Installation

```sh
kubectl get pods -n argocd
```

---

## 🔐 Accessing ArgoCD UI

### Option 1: Port Forward (Local Access)

```sh
kubectl port-forward svc/argocd-server -n argocd 8081:443
```

🌐 Access the UI at:  
```
https://localhost:8081
```

### Option 2: Expose via NodePort

1. Edit the service type:

```sh
kubectl edit svc argocd-server -n argocd
```

2. Modify:

```yaml
spec:
  type: NodePort
```

🌐 Access the UI at:  
```
http://[KUBERNETES_NODE_IP]:[NODE_PORT]
```

---

## 🔐 Logging into ArgoCD

### Retrieve the Initial Admin Password

```sh
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

> 🔒 Change the password via the UI or using the CLI after first login.

---

## 📦 Deploying Applications via ArgoCD

1. Open **ArgoCD UI → Applications → New App**.
2. Fill in the following:

| Field               | Value                                       |
|--------------------|---------------------------------------------|
| **Application Name** | `[Your Application Name]`                |
| **Project**          | `default`                                |
| **Sync Policy**      | `Automatic`                              |
| **Git Repo URL**     | `[Your GitHub Manifest Repo]`            |
| **Path**             | `./` (if manifests are in root)          |
| **Cluster URL**      | `https://kubernetes.default.svc`         |
| **Namespace**        | `default`                                |

3. Click **Create**.

---

## 🔗 ArgoCD CLI Setup

### Login to ArgoCD via CLI

```sh
argocd login [ARGOCD_SERVER_IP]:[NODE_PORT] --username admin --password [YOUR_PASSWORD]
```

### Sync Your Application(ArgoCD will automatically Syncs, Incase you want to do it manually/instamtly)

```sh
argocd app sync flaskdemo
```

---

## ✅ Summary

This setup provides an automated CI/CD pipeline using:

- **Jenkins**: Automates Docker builds and Kubernetes manifest updates.
- **Docker Hub**: Stores application images.
- **ArgoCD**: Continuously deploys updates to Kubernetes.
- **Amazon EKS**: Production-grade, managed Kubernetes cluster.

---

> 💡 For production, consider adding secrets management, RBAC, monitoring, and rollback strategies.

