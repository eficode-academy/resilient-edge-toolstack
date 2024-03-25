#!/bin/bash
      
      KUBECONFIG="/opt/kubeconfig/kubeconfig"
      TALOSCONFIG="/opt/talosconfig/talosconfig"
      SERVER_IP="192.168.1.109"
      #UPGRADE_TALOS="true"
      #TALOS_VERSION="v1.5.5"
     # UPGRADE_KUBERENTES="true"

 echo $UPGRADE_KUBERNETES
 echo $TALOS_VERSION
if [ "$UPGRADE_KUBERNETES" != "true" ] && [ "$UPGRADE_TALOS" != "true" ]; then
  echo "None of the variables UPGRADE_KUBERNETES or UPGRADE_TALOS has been set to true (true as a string, not a boolean), exiting without any upgrading"
  echo $UPGRADE_KUBERENTES
  echo $UPGRADE_TALOS
  echo $TALOS_VERSION
  exit 0
fi

check_talos_version_existence() {
    local version_url="https://github.com/siderolabs/talos/releases/tag/${TALOS_VERSION}"
    if ! curl --output /dev/null --silent --head --fail "$version_url"; then
        echo "Invalid Talos version specified in env variable: ${TALOS_VERSION}."
        exit 1
    fi
}

# Function to check talosctl version consistency
check_talosctl_version() {
    

    # Get client and server versions
    client_version=$(talosctl version -n $SERVER_IP -e $SERVER_IP  | grep 'Client:' -A 1 | grep 'Tag:' | awk '{print $2}')
    server_version=$(talosctl -e $SERVER_IP -n $SERVER_IP version | grep 'Server:' -A 2 | grep 'Tag:' | awk '{print $2}')


    if [ "$client_version" != "$server_version" ]; then
        echo "Version mismatch. Downloading server version of talosctl..."

        # Formulate download URL
        download_url="https://github.com/siderolabs/talos/releases/download/${server_version}/talosctl-linux-amd64"

        # Download new version
        #wget $download_url -O "talosctl-$server_version"
        curl -Lo "talosctl-$server_version" "$download_url"

        # Make it executable
        chmod +x "talosctl-$server_version"
    fi

}

# Upgrade Talos
upgrade_talos() {
    echo "Upgrading Talos..."
    
    ./talosctl-"${server_version}" upgrade --nodes $SERVER_IP -e $SERVER_IP  \
      --image ghcr.io/siderolabs/installer:${TALOS_VERSION} --preserve=true --stage
}

get_current_k8s_version() {
    local version_string=$(kubectl get nodes -o jsonpath="{.items[0].status.nodeInfo.kubeletVersion}")
    echo $version_string

    #local current_version=$($version_string)
    local major=$(echo $version_string | cut -d. -f1)
    local minor=$(echo $version_string | cut -d. -f2)
    local patch=$(echo $version_string | cut -d. -f3)

    if [ $patch -gt 0 ]; then
      patch=0
    fi
    local next_minor=$((minor + 1))
    echo "${major}.${next_minor}.${patch}"
    NEXT_VERSION="${major}.${next_minor}.${patch}"
}

# Upgrade Kubernetes
upgrade_kubernetes() {

    echo "Upgrading Kubernetes..."
    ./talosctl-"${server_version}" -n $SERVER_IP -e $SERVER_IP upgrade-k8s
}
# Upgrade Kubernetes
upgrade_kubernetes_specific_version() {

#as long as the current version is lower than KUBERNETES_VERSION, we keep upgrading
# parse KUBERNETES_VERSION to get the major, minor and patch versions
    local major=$(echo $KUBERNETES_VERSION | cut -d. -f1)
    local minor=$(echo $KUBERNETES_VERSION | cut -d. -f2)
    local patch=$(echo $KUBERNETES_VERSION | cut -d. -f3)

    # fetch the current version of the cluster
    local current_version=$(kubectl get nodes -o jsonpath="{.items[0].status.nodeInfo.kubeletVersion}")
    local current_major=$(echo $current_version | cut -d. -f1)
    local current_minor=$(echo $current_version | cut -d. -f2)
    local current_patch=$(echo $current_version | cut -d. -f3)

    # check if the current version is lower than the target version
    while [ $current_major -lt $major ] || [ $current_minor -lt $minor ] || [ $current_patch -lt $patch ]; do
        echo "Upgrading Kubernetes..."
        ./talosctl-"${server_version}" -n $SERVER_IP -e $SERVER_IP upgrade-k8s --to $KUBERNETES_VERSION
        current_version=$(kubectl get nodes -o jsonpath="{.items[0].status.nodeInfo.kubeletVersion}")
    done

}

if [ "$UPGRADE_TALOS" = "true" ] && [ "$UPGRADE_KUBERNETES" = "true" ] ; then
    echo "Cannot upgrade both Talos and Kubernetes at the same time."
    exit 0
elif [ "$UPGRADE_TALOS" = "true" ]; then
    check_talos_version_existence
    check_talosctl_version
    upgrade_talos
elif [ "$UPGRADE_KUBERNETES" = "true" ]; then
    check_talos_version_existence
    check_talosctl_version
    get_current_k8s_version
    if [[ -z  "$KUBERNETES_VERSION" ]]; then #if it exists
      upgrade_kubernetes_specific_version
    else
      upgrade_kubernetes
    fi
fi
