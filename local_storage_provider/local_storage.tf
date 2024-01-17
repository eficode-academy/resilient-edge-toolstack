resource "null_resource" "cluster_readiness_check" {
  triggers = {
    bootstrap_complete = var.tal_bootstrap_complete
  }
  # A simple script that checks the readiness of the Kubernetes cluster
  provisioner "local-exec" {
    command = <<EOF
      #!/bin/bash
      until kubectl --kubeconfig="${path.module}/../configs/kubeconfig" get nodes | grep -m 1 'Ready'; do 
        echo 'Waiting for Kubernetes cluster to be ready...'
        sleep 15
      done
      kubectl --kubeconfig="${path.module}/../configs/kubeconfig" apply -n local-path-storage -f ${path.module}/k8s_manifests/namespace.yaml
      kubectl --kubeconfig="${path.module}/../configs/kubeconfig" apply -n local-path-storage -f ${path.module}/k8s_manifests/install.yaml
      kubectl --kubeconfig="${path.module}/../configs/kubeconfig" apply -f ${path.module}/k8s_manifests/pvc.yaml
    EOF
    interpreter = ["/bin/bash", "-c"]
  }
}
