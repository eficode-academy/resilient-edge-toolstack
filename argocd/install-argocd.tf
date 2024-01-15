provider "kubectl" {
  config_path = "./configs/kubeconfig"
}

data "kubectl_file_documents" "namespace" {
    content = file("argocd/k8s_manifests/namespace.yaml")
} 

data "kubectl_file_documents" "argocd" {
    content = file("argocd/k8s_manifests/install.yaml")
}

resource "kubectl_manifest" "namespace" {
    count     = length(data.kubectl_file_documents.namespace.documents)
    yaml_body = element(data.kubectl_file_documents.namespace.documents, count.index)
    override_namespace = "argocd"
}

resource "kubectl_manifest" "argocd" {
    depends_on = [
      kubectl_manifest.namespace,
    ]
    count     = length(data.kubectl_file_documents.argocd.documents)
    yaml_body = element(data.kubectl_file_documents.argocd.documents, count.index)
    override_namespace = "argocd"
}
