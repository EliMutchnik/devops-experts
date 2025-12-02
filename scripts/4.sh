kubectl get pods

# Creating a Persistent Volume
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/pv.yaml
kubectl describe pv

# Creating a Persistent Volume Claim
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/pvc.yaml
kubectl describe persistentvolumeclaim/task-pv-claim

# Creating a Pod with volume
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/pod-with-pvc.yaml
kubectl describe pod task-pv-pod

# Checking the mount
kubectl exec -it task-pv-pod -- bash
cd /usr/share/nginx/html/
echo 1 > index.html
exit
kubectl get pv
kubectl describe pv <ID>
kubectl debug node/docker-desktop -it --image=busybox -- sh
kubectl delete -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/pod-with-pvc.yaml

# Local dir
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/pod-empty-dir.yaml
kubectl exec -it test-pd -- bash

# Config maps
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/config-map.yaml
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/game-config.yaml
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/pod-with-config-map.yaml
kubectl exec -it pod-env-var -- bash
cat /app/game.properties
exit
kubectl describe configmap game-config

# Secrets
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/secret.yaml
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/pod-with-secret.yaml

# StatefullSets
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/statefulset.yaml
kubectl scale sts/postgres --replicas=5

# DaemonSets
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/daemonset.yaml

# CronJob
kubectl apply -f https://raw.githubusercontent.com/avielb/k8s-demo/refs/heads/master/volumes/cronjob.yaml

# Extras: PodDisruptionBudget, PriorityClass, ResourceQuota
