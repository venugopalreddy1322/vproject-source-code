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
## 🗂️ Repository Structure

### 🔹 1. Application Source Code Repository  
**GitHub Repo:** `https://github.com/venugopalreddy1322/vproject-git-argo-k8`
#### Contains:
| File/Folder      | Description |
|------------------|-------------|
| `app.py`         | A simple **Flask**-based Python application that returns a "Hello" message. |
| `requirements.txt` | Python dependencies for the app (Flask, etc.). |
| `Dockerfile`     | Docker configuration to containerize the app. |
| `Jenkinsfile`    | CI pipeline to build, tag, and push the Docker image, then trigger manifest update. |
| `.gitignore`     | Excludes unnecessary files from Git. |

---
### 🔹 2. Kubernetes Manifest Repository  
**GitHub Repo:** `https://github.com/venugopalreddy1322/vproject-k8-manifest`

#### Contains:
| File/Folder      | Description |
|------------------|-------------|
| `deployment.yaml`| Kubernetes Deployment manifest. Updated automatically by Jenkins with new image tags. |
| `vservice.yaml`  | Kubernetes Service manifest to expose the application. |
| `Jenkinsfile`    | Pipeline to update image in `deployment.yaml` and commit to repo (triggered by Jenkinsfile1). |
| `.gitignore`     | Excludes unnecessary files from Git. |


For webhook to trigger Jenkins job
Settings of repo to synch --> webhook --> add webhook ---> Payload URL:<http://static-ip of Jenkins-server>:8080/github-webhook/  --->Content Type: application/json --> select 'Just the Push event' --> Click 'Add webhook'

Then Goto Jenkins UI --> Your job --> configure --> Under 'Build Triggers' select 'GitHub hook trigger for GITScm Poling' --> Save


install ArgoCD

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
After restarting, check if it's running:

kubectl get pods -n argocd

kubectl port-forward svc/argocd-server -n argocd 8081:443

1. The API server can then be accessed using https://localhost:8081
Note: $ hostname I to get ip of wsl
OR
2. Change Service Type to NodePort
If you want persistent access, change the ClusterIP to NodePort:

Edit argocd-server service:
kubectl edit svc argocd-server -n argocd

spec:
  type: NodePort

Access via:
http://<WSL-IP>:<NodePort>

username: admin
for password: 
$ argocd admin initial-password -n argocd

Then change the password
Next 
Applications--> New App --> Application name: <name of appl> project name :default Sync plicy: Automatic --> SOURCE: --> <Git repo url> , path : ./ (if manifests are in root directory)
DESTINATION:
Cluster URL: https://kubernetes.default.svc (If ArgoCD is on the same cluster as destination cluster), Namespace: default

CREATE

-----------------------------

To connect argicd server and sync application with repo
  
  $  argocd login 172.30.130.64:32014 --username admin --password xxxxxx

  $  argocd app sync flaskdemo

---
