### Setup ###

# Deploy ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get all -n argocd

# Login to ArgoCD
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n argocd | base64 -d; echo
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Go to localhost:8080, User: admin


############ Ex1 ############
# Create a new repo
Create new repo called: devops-lesson8-argocd
https://github.com/new

# Add those files under ex1 folder: 
https://github.com/EliMutchnik/devops-experts/tree/main/argocd/ex1/deployment.yaml
https://github.com/EliMutchnik/devops-experts/tree/main/argocd/ex1/svc.yaml
# Create a new ArgoCD application manually via UI - point it to 
# Change replicas and see the impact


############ Ex2 ############
# Deploying Helm chart via ArgoCD
# Create and commit new helm chart (mychart) in the repo root

# Create ArgoCD application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myrelease
spec:
  project: default
  source:
    repoURL: https://github.com/<USERNAME>/devops-lesson8-argocd.git
    path: mychart
    targetRevision: HEAD
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

# Use multiple values
values-dev.yaml - replicaCount: 2
values-prod.yaml - replicaCount: 4


############ Ex3 ############
# Hooks and Waves demo
# Add those files under ex3 folder: 
https://github.com/EliMutchnik/devops-experts/blob/main/argocd/ex3/sync-wave.yaml

# Create ArgoCD application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sync-waves-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<USERNAME>/devops-lesson8-argocd.git
    targetRevision: HEAD
    path: ex3
  destination:
    server: https://kubernetes.default.svc
    namespace: sync-waves-demo
  syncPolicy:
    automated: 
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true


############ Ex4 ############
# App of Apps

# --- parent.yaml ---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<USERNAME>/devops-lesson8-argocd.git
    path: ex4/apps
    targetRevision: HEAD
    directory:
      recurse: false
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
 
# --- ex4/apps/ex1-app.yaml ---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ex1-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io   # delete child -> cascade delete its workloads
spec:
  project: default
  source:
    repoURL: https://github.com/<USERNAME>/devops-lesson8-argocd.git
    path: ex1
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: app-of-apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true

 
# --- ex4/apps/ex2-app.yaml ---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: helm-app
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/<USERNAME>/devops-lesson8-argocd.git
    path: ex2/mychart
    targetRevision: HEAD
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: app-of-apps
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true


# Class Exercise
1. Write a Kubernetes application (yaml file/s) that displays a custom HTML page
2. Deploy it using ArgoCD using the UI / yaml (better)
3. Update website only using Git.

# Someting to start with:

apiVersion: v1
kind: ConfigMap
metadata:
  name: my-website-config
  namespace: student-apps
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head><title>GitOps Demo</title></head>
    <body style="background-color: #2d3436; color: white; text-align: center; padding-top: 50px;">
      <h1>Hello Class 1125!</h1>
      <p>Deployed via ArgoCD</p>
    </body>
    </html>
---
apiVersion: v1
kind: Service
.
.
.
---
apiVersion: apps/v1
kind: Deployment
.
.
.
