#!/bin/bash

# Variables
PROJECT_ID="world-learning-400909"
GCP_SERVICE_ACCOUNT="gke-sa@$PROJECT_ID.iam.gserviceaccount.com"
K8S_SERVICE_ACCOUNT="gke-sa"
CLUSTER_NAME="disearch-cluster"
CLUSTER_ZONE="us-central1-c"
SERVICE_ACCOUNT="jenkins@$PROJECT_ID.iam.gserviceaccount.com"

# Authenticate with service account
export GOOGLE_APPLICATION_CREDENTIALS="/workspace/secret.json"
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Set configurations
gcloud config set account ${SERVICE_ACCOUNT}
gcloud config set project ${PROJECT_ID}

# Connect to the cluster
gcloud container clusters get-credentials $CLUSTER_NAME --zone $CLUSTER_ZONE --project $PROJECT_ID

# Get namespaces starting with 'apptest'
NAMESPACES=$(kubectl get ns --no-headers -o custom-columns=":metadata.name" | grep '^apptest')

# Loop through each namespace
for NAMESPACE in $NAMESPACES; do
  echo "Processing namespace: $NAMESPACE"

  # Add IAM policy binding
  gcloud iam service-accounts add-iam-policy-binding $GCP_SERVICE_ACCOUNT \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$K8S_SERVICE_ACCOUNT]"

  # Annotate Kubernetes service account
  kubectl annotate serviceaccount $K8S_SERVICE_ACCOUNT \
    --namespace $NAMESPACE \
    iam.gke.io/gcp-service-account=$GCP_SERVICE_ACCOUNT

  # Get service account details
  kubectl get sa/gke-sa -o yaml -n $NAMESPACE
done

# Confirmation message
echo "IAM policy bindings and annotations applied successfully for namespaces starting with 'apptest'."
