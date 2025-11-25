# Init setup
kubectl config use-context docker-desktop
kubectl get namespaces
kubectl get pods
kubectl get pods --all-namespaces
kubectl get pods -n kube-system
kubectl describe node docker-desktop

# Creating NS
kubectl create ns devops1125
kubectl ns devops1125
kubectl config view --minify | grep namespace:

# Running first Pod
kubectl run nginx --image=nginx:1.29-alpine
kubectl describe pod nginx
kubectl delete pod nginx

# Creating first deployment (watch kubectl get pods)
kubectl create deployment hello-node --image=nginx:alpine --replicas=5
kubectl describe deployment hello-node
kubectl describe replicasets hello-node-<ID>
kubectl get deployment hello-node -o yaml

# Modifing first deployment
kubectl scale deployment hello-node --replicas=20
kubectl set image deploy/hello-node nginx=nginx:latest
kubectl describe deployment hello-node
kubectl get deployment hello-node -o yaml

# Networking
kubectl expose deploy/hello-node --type ClusterIP --port 80
kubectl describe service hello-node
kubectl scale deployment hello-node --replicas=2
kubectl delete service hello-node
kubectl expose deploy/hello-node --type NodePort --port 80
kubectl port-forward svc/hello-node 8989:80

# Deploying yaml
----------
apiVersion: v1
kind: Service
metadata:
  name: fe-gate
spec:
  selector:
    name: nginx
  type: NodePort
  ports:
  - name: foo
    port: 80
    targetPort: 80
  - name: bar
    port: 8081
    targetPort: 8081
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    name: nginx
spec:
  #hostname: frontend001
  containers:
  - image: nginx
    name: nginx-container
---
apiVersion: v1
kind: Pod
metadata:
  name: debian
  labels:
    name: debian
spec:
  containers:
  - image: debian
    name: debian-container
    command:
      - sleep
      - "3600"
-------

kubectl exec -it <POD ID> -- bash

# Understanding yamls
https://github.com/avielb/k8s-demo/blob/master/guestbook/100-rows.yaml


kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/guestbook/cronjob.yaml
