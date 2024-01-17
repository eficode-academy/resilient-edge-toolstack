#!/bin/bash

#cd /Users/danielr/work/k8s-edge-old/k8s-edge-infra

KUBECONFIG=configs/kubeconfig

files=("kubeconfig" "talosconfig")

config_dir="configs"

# Deployment and namespace
DEPLOYMENT_NAME="management-deployment"
NAMESPACE="management"
CONTAINER_NAME="management-container"

# Initialize patch command for volume and volumeMounts
VOLUMES_PATCH=""
VOLUME_MOUNTS_PATCH=""

for file in "${files[@]}"; do
    # Base64 encode the file
    encoded_file=$(base64 -w 0 "${config_dir}/${file}")

    # Create the Kubernetes secret manifest
    cat <<EOF > "${config_dir}/${file}-secret.yaml"
apiVersion: v1
kind: Secret
metadata:
  name: "${file}-secret"
type: Opaque
data:
  ${file}: $encoded_file
EOF

    echo "Kubernetes secret manifest created: ${config_dir}/${file}-secret.yaml"

    # Apply the secret manifest
    kubectl apply -n $NAMESPACE -f "${config_dir}/${file}-secret.yaml"

    # Append to the volumes patch
    VOLUMES_PATCH="${VOLUMES_PATCH}{\"name\":\"${file}-volume\",\"secret\":{\"secretName\":\"${file}-secret\"}},"

    # Append to the volumeMounts patch
    MOUNT_PATH="/var/run/secrets/"
    VOLUME_MOUNTS_PATCH="${VOLUME_MOUNTS_PATCH}{\"name\":\"${file}-volume\",\"mountPath\":\"${MOUNT_PATH}\"},"
done

# Remove trailing commas
VOLUMES_PATCH="[${VOLUMES_PATCH%,}]"
VOLUME_MOUNTS_PATCH="[${VOLUME_MOUNTS_PATCH%,}]"

# Create the full patch JSON
PATCH=$(cat <<EOF
[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes",
    "value": $VOLUMES_PATCH
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts",
    "value": $VOLUME_MOUNTS_PATCH
  }
]
EOF
)

# Apply the patch to the deployment
kubectl patch deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" --type='json' -p="$PATCH"


