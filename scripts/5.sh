kubectl get pods 

helm list

# Creating chart
helm create mychart
cd mychart
helm template mychart ./

# Upgrading and rolling back
helm upgrade -i myrelease ./
helm list
## change replicaCount to 3
helm upgrade -i myrelease ./
helm history myrelease

# How helm manage revisions
kubectl get secrets

helm get manifest myrelease --revision 1
helm get manifest myrelease --revision 2
helm rollback myrelease

# Pass external values
helm get values myrelease
## in a new file called `values-prod.yaml` write replicaCount: 5
helm upgrade -i myrelease -f values-prod.yaml ./
helm get values myrelease

# Pushing chart
helm package ./mychart
## to create a token:
https://app.docker.com/settings/personal-access-tokens
helm registry login registry-1.docker.io -u <username>
helm push mychart-0.1.0.tgz oci://registry-1.docker.io/<username>
helm fetch --untar oci://registry-1.docker.io/elimutch/mychart --version 0.1.0
helm upgrade -i myrelease oci://registry-1.docker.io/elimutch/mychart --version 0.1.0 --set replicaCount=3

# Playing with ArifactHub
https://artifacthub.io/
helm upgrade -i redis oci://registry-1.docker.io/bitnamicharts/redis

helm uninstall myrelease redis
