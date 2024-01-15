provider "kubectl" {
  config_path = "./configs/kubeconfig"
}

data "kubectl_file_documents" "namespace_storage" {
    content = file("local_storage_provider/k8s_manifests/namespace.yaml")
} 

data "kubectl_file_documents" "storage" {
    content = file("local_storage_provider/k8s_manifests/install.yaml")
}

data "kubectl_file_documents" "pvc" {
    content = file("local_storage_provider/k8s_manifests/pvc.yaml")
}

resource "kubectl_manifest" "namespace_storage" {
    count     = length(data.kubectl_file_documents.namespace_storage.documents)
    yaml_body = element(data.kubectl_file_documents.namespace_storage.documents, count.index)
    override_namespace = "local-path-storage"
}

resource "kubectl_manifest" "local-path-storage" {
    depends_on = [
      kubectl_manifest.namespace_storage,
    ]
    count     = length(data.kubectl_file_documents.storage.documents)
    yaml_body = element(data.kubectl_file_documents.storage.documents, count.index)
    override_namespace = "local-path-storage"
}

resource "kubectl_manifest" "pvc" {
    depends_on = [
      kubectl_manifest.namespace_storage,
    ]
    count     = length(data.kubectl_file_documents.pvc.documents)
    yaml_body = element(data.kubectl_file_documents.pvc.documents, count.index)
    override_namespace = "local-path-storage"
}
