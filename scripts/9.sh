git clone https://github.com/avielb/advanced-devops.git
cd advanced-devops/monitoring/k8s-setup

# Create monitoring namespace
kubectl create namespace monitoring

# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm upgrade -i prometheus prometheus-community/prometheus --namespace monitoring -f prometheus/values.yml
kubectl patch ds prometheus-prometheus-node-exporter --type "json" -p '[{"op": "remove", "path" : "/spec/template/spec/containers/0/volumeMounts/2/mountPropagation"}]' -n monitoring

# Install Grafana
kubectl apply -f monitoring/grafana/config.yml
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana --namespace monitoring grafana/grafana --set rbac.pspEnabled=false

### Node Exporter
kubectl -n monitoring port-forward svc/prometheus-prometheus-node-exporter 9100:9100

### Prometheus Server
kubectl -n monitoring port-forward svc/prometheus-server 9090:80
# PromQL examples:
1. 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
2. (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
3. node_filesystem_avail_bytes / node_filesystem_size_bytes * 100
4. sum by (device) (rate(node_network_receive_bytes_total[5m]) + rate(node_network_transmit_bytes_total[5m]))

### Push Gateway
kubectl -n monitoring port-forward svc/prometheus-prometheus-pushgateway 9091:9091
echo "some_metric 1125" | curl --data-binary @- http://localhost:9091/metrics/job/some_job/a/b

### Alert Manager
kubectl -n monitoring port-forward svc/prometheus-alertmanager 9093:9093

### Grafana
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl -n monitoring port-forward svc/grafana 3000:80
# Setup http://prometheus-server as data source

# kube-state-metrics grafana-dashboard id: 6417

# Deploy nginx Ingress
helm install my-nginx ingress-nginx/ingress-nginx \
  --set controller.metrics.enabled=true \
  --set-string controller.podAnnotations.prometheus\.io/scrape="true" \
  --set-string controller.podAnnotations.prometheus\.io/port="10254"

# nginx Ingress grafana dashboard id: 16677
