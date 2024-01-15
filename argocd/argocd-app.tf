data "kubectl_file_documents" "hello-python-application" {
    content = file("argocd/applications_manifests/argocd-hello-python.yaml")
}

# data "kubectl_file_documents" "my-app1-app" {
#     content = file("./argocd/my-app1-app.yaml")
# }

# data "kubectl_file_documents" "my-secret" {
#     content = file("./github-secret.yaml")
# }


# resource "kubectl_manifest" "my-secret" {
#     depends_on = [
#       kubectl_manifest.argocd,
#     ]
#     count     = length(data.kubectl_file_documents.my-secret.documents)
#     yaml_body = element(data.kubectl_file_documents.my-secret.documents, count.index)
# }

resource "kubectl_manifest" "hello-python-application" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.hello-python-application.documents)
    yaml_body = element(data.kubectl_file_documents.hello-python-application.documents, count.index)
}

# resource "kubectl_manifest" "my-app1-app" {
#     depends_on = [
#       kubectl_manifest.argocd,
#     ]
#     count     = length(data.kubectl_file_documents.my-app1-app.documents)
#     yaml_body = element(data.kubectl_file_documents.my-app1-app.documents, count.index)
# }