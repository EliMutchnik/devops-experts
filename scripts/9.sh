git clone https://github.com/avielb/advanced-devops.git
cd monitoring/k8s-setup

# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm upgrade -i prometheus prometheus-community/prometheus --namespace monitoring -f prometheus/values.yml

# Install Grafana
kubectl apply -f monitoring/grafana/config.yml
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana --namespace monitoring grafana/grafana --set rbac.pspEnabled=false


### Node Exporter
kubectl -n monitoring port-forward svc/prometheus-prometheus-node-exporter 9100:9100

### Prometheus Server
kubectl -n monitoring port-forward svc/prometheus-server 9090:80

### Push Gateway
kubectl -n monitoring port-forward svc/prometheus-prometheus-pushgateway 9091:9091
echo "some_metric 52" | curl --data-binary @- http://localhost:9091/metrics/job/some_job/a/b

### Alert Manager
kubectl -n monitoring port-forward svc/prometheus-alertmanager 9093:9093

### Grafana
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl -n monitoring port-forward svc/grafana 3000:80

