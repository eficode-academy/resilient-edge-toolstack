 #!/bin/bash
      
      KUBECONFIG="configs/kubeconfig"
      TALOSCONFIG="configs/talosconfig"

      kubectl apply -f management/k8s_manifests/namespace.yaml
        # Define the Talos server IP address

        SERVER_IP="192.168.1.109"

        # Get client and server versions
        client_version=$(talosctl version -n $SERVER_IP -e $SERVER_IP  | grep 'Client:' -A 1 | grep 'Tag:' | awk '{print $2}')
        server_version=$(talosctl -e $SERVER_IP -n $SERVER_IP version | grep 'Server:' -A 2 | grep 'Tag:' | awk '{print $2}')

        echo "Client Version: $client_version"
        echo "Server Version: $server_version"

        # Compare and download if necessary
        if [ "$client_version" != "$server_version" ]; then
            echo "Version mismatch. Downloading server version of talosctl..."

            # Formulate download URL
            download_url="https://github.com/siderolabs/talos/releases/download/${server_version}/talosctl-linux-amd64"

            # Download new version
            wget $download_url -O "talosctl-$server_version"

            # Make it executable
            chmod +x "talosctl-$server_version"
            
            ./talosctl-"${server_version}" inject serviceaccount -f management/k8s_manifests/management-deployment.yaml > management/k8s_manifests/management-deployment-injected.yaml

            kubectl apply -n management -f management/k8s_manifests/management-deployment-injected.yaml
            
        else
            talosctl inject serviceaccount -f management/k8s_manifests/talos-api-access.yaml > management/k8s_manifests/management-deployment-injected.yaml

            kubectl apply -n management -f management/k8s_manifests/management-deployment-injected.yaml
        fi

./generate-secret.sh
