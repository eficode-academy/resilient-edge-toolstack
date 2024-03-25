# Resilient Edge Toolstack "RET" Upgrader

## Usage

There are four environment variables to set in order for this to work:

- `UPGRADE_TALOS` - Set to "true" if you want to upgrade Talos
- `TALOS_VERSION` - The version of Talos you want to upgrade to
- `UPGRADE_KUBERNETES` - Set to "true" if you want to upgrade Kubernetes
- `KUBERNETES_VERSION` - The version of Kubernetes you want to upgrade to

> :bulb: The versions of Talos and Kubernetes must be compatible with each other. Check the [Talos release notes](https://github.com/siderolabs/talos/releases)

> :bulb: The version that will be upgraded to cannot be guarenteed to be the version that will be installed. The latest version that is available from the tool will be installed.


Example:

``` yaml
          - name: UPGRADE_TALOS #Select if you want to upgrade Talos
            value: "true"
          - name: TALOS_VERSION #Select the version of Talos you want to upgrade to
            value: "v1.4.8"
          - name: UPGRADE_KUBERNETES #Select if you want to upgrade Kubernetes
            value: "true"
          - name: KUBERNETES_VERSION #Select the version of Kubernetes you want to upgrade to
            value: "v1.27.4"
```


## Usage

``` YAML
apiVersion: batch/v1
kind: Job
metadata:
  name: upgrade-edge
  namespace: management
spec:
  backoffLimit: 0 
  template:
    spec:
      containers:
      - name: upgrade-edge-container
        image: ghcr.io/eficode-academy/edgek8s-upgrade:latest
        env:
          # - name: UPGRADE_TALOS
          #   value: "true"
          - name: TALOS_VERSION
            value: "v1.4.8"
          - name: UPGRADE_KUBERNETES
            value: "true"
          - name: KUBERNETES_VERSION
            value: "v1.27.4"
        volumeMounts:
        - mountPath: /var/run/secrets/talos.dev
          name: talos-secrets
        - mountPath: /opt/kubeconfig
          name: kubeconfig-volume
        - mountPath: /opt/talosconfig
          name: talosconfig-volume
      volumes:
      - name: talos-secrets
        secret:
          secretName: management-deployment-talos-secrets
      - name: kubeconfig-volume
        secret:
          defaultMode: 420
          secretName: kubeconfig-secret
      - name: talosconfig-volume
        secret:
          defaultMode: 420
          secretName: talosconfig-secret
      restartPolicy: Never
```