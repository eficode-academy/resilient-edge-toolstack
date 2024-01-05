data "kubectl_file_documents" "my-common-app" {
    content = file("./argocd/my-common-app.yaml")
}

data "kubectl_file_documents" "my-app1-app" {
    content = file("./argocd/my-app1-app.yaml")
}

data "kubectl_file_documents" "my-secret" {
    content = file("./github-secret.yaml")
}


resource "kubectl_manifest" "my-secret" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.my-secret.documents)
    yaml_body = element(data.kubectl_file_documents.my-secret.documents, count.index)
}

resource "kubectl_manifest" "my-common-app" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.my-common-app.documents)
    yaml_body = element(data.kubectl_file_documents.my-common-app.documents, count.index)
}

resource "kubectl_manifest" "my-app1-app" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.my-app1-app.documents)
    yaml_body = element(data.kubectl_file_documents.my-app1-app.documents, count.index)
}