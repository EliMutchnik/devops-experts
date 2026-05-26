kubectl get pods 

helm list

## values.yaml - {{ .Values.x }} usage in templates/
## templates/_helpers.tpl — named templates via include
## Chart.yaml: version (the chart's own version) vs appVersion (the app it ships)
## templates/NOTES.txt — this is what prints after install/upgrade


# Creating chart
helm create mychart
cd mychart
helm template mychart ./
helm template mychart ./ --debug    # full error output when rendering breaks
helm lint ./                        # catch chart structure / schema errors early

helm install myrelease ./ --dry-run --debug

# Upgrading and rolling back
helm upgrade -i myrelease ./
helm status myrelease               # release state, revision, notes in one view
helm list
## change replicaCount to 3
helm upgrade -i myrelease ./ --dry-run
helm upgrade -i myrelease ./
helm history myrelease

# How helm manage revisions
kubectl get secrets

helm get manifest myrelease --revision 1
helm get manifest myrelease --revision 2
helm get all myrelease              # manifest + values + hooks + notes, everything
helm rollback myrelease
helm upgrade -i myrelease ./ --atomic    # --atomic on upgrade auto-rolls-back on failure

# Diffing changes before you apply them (helm-diff plugin)
helm plugin install https://github.com/databus23/helm-diff
helm plugin list
helm diff upgrade myrelease ./


# Pass external values
helm get values myrelease
## in a new file called `values-prod.yaml` write replicaCount: 5
helm upgrade -i myrelease -f values-prod.yaml ./
helm get values myrelease

helm upgrade -i myrelease -f values-prod.yaml --set replicaCount=9 ./    # --set beats -f
helm get values myrelease


# Pushing chart
helm package ./mychart
## to create a token:
https://app.docker.com/settings/personal-access-tokens
helm registry login registry-1.docker.io -u <username>
helm push mychart-0.1.0.tgz oci://registry-1.docker.io/<username>
helm pull --untar oci://registry-1.docker.io/elimutch/mychart --version 0.1.0
helm upgrade -i myrelease oci://registry-1.docker.io/elimutch/mychart --version 0.1.0 --set replicaCount=3


# Playing with ArifactHub
https://artifacthub.io/
helm upgrade -i nginx oci://registry-1.docker.io/bitnamicharts/nginx
helm uninstall myrelease nginx

# Dependencies / subcharts — from "build your own" to "consume others"
## in Chart.yaml add a dependencies: block pointing at the bitnami redis chart
dependencies:
  - name: postgresql
    version: "~16.0.0"
    repository: "oci://registry-1.docker.io/bitnamicharts"

helm dependency update ./mychart    # pulls deps into charts/
helm dependency list ./mychart      # show declared deps and their status


# Class exercise
## Create a new chart, with 5 replicas of nginx:alpine image. 
## Deploy it, package it and push to your Dockerhub.
## Uninstall local chart installation and install it from the Dockerhub repo
