# Deploy ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get all -n argocd

# Login to ArgoCD

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n argocd | base64 -d; echo
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Login to localhost:8080

# Create a new repo
create new repo called: devops-1125-argocd
https://github.com/new
# Add those files: 
https://github.com/EliMutchnik/devops-experts/tree/main/argocd/deployment.yaml
https://github.com/EliMutchnik/devops-experts/tree/main/argocd/svc.yaml

# Create a new ArgoCD application
# Change replicas and see the impact

# Deploying Helm chart via ArgoCD

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myrelease
spec:
  project: default
  source:
    repoURL: https://github.com/avielb/advanced-devops.git
    path: gitops/argocd/mychart
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
https://github.com/avielb/advanced-devops/tree/master/gitops/argocd/mychart
values-dev.yaml
values-prod.yaml


# Hooks and Waves demo
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 02-sync-waves-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: HEAD
    path: sync-waves
  destination:
    server: https://kubernetes.default.svc
    namespace: sync-waves-demo
  syncPolicy:
    automated: 
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
