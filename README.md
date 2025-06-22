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
   ## NOTE:(IF YOU INSTALL JENKINS SERVER ON WSL2)
   a common setup issue when using Jenkins on WSL2. Your Jenkins server is working internally, but GitHub can’t reach the WSL2-hosted webhook because:

⚠️ WSL2 IP addresses (like 172.30.130.64) are not reachable from the public internet.

So while your browser (on the same machine or LAN) can access http://172.30.130.64:8082, GitHub's webhook service cannot connect to a private/internal IP like that.
FIX:
✅ Fix: Expose Jenkins Webhook to GitHub Using ngrok
GitHub needs a public URL to send webhook POST requests to. You can solve this by tunneling your local Jenkins server to the internet using ngrok:

🔧 Steps
Install ngrok (if not already):
Install ngrok via Apt with the following command:

```sh
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && sudo apt install ngrok
```
Run the following command to add your authtoken to the default ngrok.yml configuration file.
```sh
ngrok config add-authtoken xxxxxxxxxxxx
```
Start ngrok on your Jenkins port (8082):
```sh
hostname -I   (to get wsl ip address)
ngrok http http://wsl-IP:8082
```
Copy the public URL, e.g. https://abcd1234.ngrok.io.

Update your GitHub webhook URL to:

https://abcd1234.ngrok.io/github-webhook/


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

a common setup issue when using Jenkins on WSL2. Your Jenkins server is working internally, but GitHub can’t reach the WSL2-hosted webhook because:

⚠️ WSL2 IP addresses (like 172.30.130.64) are not reachable from the public internet.

So while your browser (on the same machine or LAN) can access http://172.30.130.64:8082, GitHub's webhook service cannot connect to a private/internal IP like that.

✅ Fix: Expose Jenkins Webhook to GitHub Using ngrok
GitHub needs a public URL to send webhook POST requests to. You can solve this by tunneling your local Jenkins server to the internet using ngrok:

🔧 Steps
Install ngrok (if not already):

```bash
sudo apt install unzip
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin
```
Start ngrok on your Jenkins port (8082):



ngrok http 8082
You’ll see output like:

nginx
Copy
Edit
Forwarding                    https://abcd1234.ngrok.io -> http://localhost:8082
Copy the public URL, e.g. https://abcd1234.ngrok.io.

Update your GitHub webhook URL to:

bash
Copy
Edit
https://abcd1234.ngrok.io/github-webhook/
Save, then click "Redeliver" on the GitHub webhook page to test it.

✅ Also: Confirm Jenkins GitHub Webhook Endpoint
Your Jenkins webhook endpoint should be:

arduino
Copy
Edit
https://your-public-url/github-webhook/
You can confirm Jenkins is set up to receive GitHub webhooks via:

Jenkins > Manage Jenkins > Configure System

Look for the GitHub plugin section

Check that GitHub Web Hook is enabled

Also verify that the Jenkins job has:

"GitHub project" URL set correctly

"Build when a change is pushed to GitHub" checked (in Build Triggers)

✅ Optional: Auto-start ngrok with consistent subdomain
If you want to keep the same URL without changing the webhook every time:

Sign up for ngrok

Use a reserved domain with:

bash
Copy
Edit
ngrok config add-authtoken YOUR_TOKEN
ngrok http --domain=yourcustomsub.ngrok.io 8082

## ✅ Summary

This setup provides an automated CI/CD pipeline using:

- **Jenkins**: Automates Docker builds and Kubernetes manifest updates.
- **Docker Hub**: Stores application images.
- **ArgoCD**: Continuously deploys updates to Kubernetes.
- **Amazon EKS**: Production-grade, managed Kubernetes cluster.

---

> 💡 For production, consider adding secrets management, RBAC, monitoring, and rollback strategies.

