 #!/bin/sh
      
      KUBECONFIG="/opt/kubeconfig/kubeconfig"
      TALOSCONFIG="/opt/talosconfig/talosconfig"
      SERVER_IP="192.168.1.109"
      #UPGRADE_TALOS="true"
      #TALOS_VERSION="v1.5.5"
      #UPGRADE_KUBERENTES="true"

if [[ "$UPGRADE_KUBERNETES" != "true" ]] || [[ "$UPGRADE_TALOS" != "true" ]] ; then
  echo "None of the variables UPGRADE_KUBERNETES or UPGRADE_TALOS has been set to true (true as a string, not a boolean), exiting without any upgrading"
  echo $UPGRADE_KUBERENTES
  echo $UPGRADE_TALOS
  echo $TALOS_VERSION
  exit 0
fi

check_talos_version_existence() {
    local version_url="https://github.com/siderolabs/talos/releases/tag/${TALOS_VERSION}"
    if ! curl --output /dev/null --silent --head --fail "$version_url"; then
        echo "Invalid Talos version: ${TALOS_VERSION}."
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
    local next_minor=$((minor + 1))
    echo "${major}.${next_minor}.${patch}"
    NEXT_VERSION="${major}.${next_minor}.${patch}"
}

# Upgrade Kubernetes
upgrade_kubernetes() {

    echo "Upgrading Kubernetes to version $NEXT_VERSION..."
    ./talosctl-"${server_version}" -n $SERVER_IP -e $SERVER_IP upgrade-k8s --to $NEXT_VERSION
}

if [ "$UPGRADE_TALOS" = "true" ] && [ "$UPGRADE_KUBERENTES" = "true" ]; then
    echo "Cannot upgrade both Talos and Kubernetes at the same time."
    exit 0
elif [ "$UPGRADE_TALOS" = "true" ]; then
    check_talos_version_existence
    check_talosctl_version
    upgrade_talos
elif [ "$UPGRADE_KUBERENTES" = "true" ]; then
    check_talosctl_version
    get_current_k8s_version
    upgrade_kubernetes
fi
