# Deploy Tekton Core 
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Deploy Tekton Triggers
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Deploy Tekton Dashboard
kubectl apply -f https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml