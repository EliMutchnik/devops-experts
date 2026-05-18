kubectl get pods

# Creating a Persistent Volume
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/pv.yaml
kubectl describe pv

# Creating a Persistent Volume Claim
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/pvc.yaml
kubectl describe persistentvolumeclaim/task-pv-claim

# Creating a Pod with volume
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/pod-with-pvc.yaml
kubectl describe pod task-pv-pod

# Checking the mount
kubectl exec -it task-pv-pod -- sh
cd /usr/share/nginx/html/
echo 1 > index.html
exit
kubectl get pv
kubectl describe pv <ID>
kubectl debug node/<NODE NAME> -it --image=busybox -- sh
kubectl delete -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/pod-with-pvc.yaml

# Local dir
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/pod-empty-dir.yaml
kubectl exec -it test-pd -- sh

# Config maps
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/config-map.yaml
kubectl get configmaps
kubectl describe configmaps <NAME OF CONFIGMAP>

kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/game-config.yaml
kubectl describe configmap game-config

kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/pod-with-config-map.yaml
kubectl exec -it pod-env-var -- sh
env
cat /app/game.properties
exit

# Secrets
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/secret.yaml
kubectl describe secret <SECRET NAME>
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/pod-with-secret.yaml
kubectl exec -it secret-pod -- sh

# StatefullSets
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/statefulset.yaml
kubectl scale sts/postgres --replicas=5

# DaemonSets
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/daemonset.yaml

# CronJob
kubectl apply -f https://raw.githubusercontent.com/EliMutchnik/devops-experts/refs/heads/main/k8s/volumes/cronjob.yaml

# Extras: PodDisruptionBudget, PriorityClass, ResourceQuota
