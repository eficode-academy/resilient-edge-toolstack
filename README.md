

# tested using image below

docker run -it -v /Users/danielr/work/k8s-edge-ansible:/k8s-edge-ansible devture/ansible:latest

```kubectl get pods -n argocd --kubeconfig=configs/kubeconfig```

ArgoCD can be accessed on the link after port forwarding 

```kubectl port-forward svc/argocd-server -n argocd 8080:443 -n argocd --kubeconfig=configs/kubeconfig``` 

and the credentials to access are present in the secret argocd-initial-admin-secret. These credentials need to be updated after the first login, and this would be a manual process. 

You can retrieve the password using the command below:

```kubectl --kubeconfig=configs/kubeconfig -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo```


ansible-playbook playbooks/edgek8s-complete-provision.yml

docker run -it -v /Users/danielr/work/k8s-edge-ansible:/k8s-edge-ansible eficode-academy/edge-k8s-ansible-provision:latest ansible-playbook playbooks/edgek8s-complete-provision.yml

talosctl -n 192.168.1.109 disks --insecure


############################################################################### OLD DOCS BELOW

# k8s-talos-terraform

## Information:
There are 2 Git repos:
1. Containing the Terraform code (this repository)

2. Containing the GitOps code (the applications in K8s cluster) 


### WIP
#### Prerequisites:
An USB stick burned with ISO image of Talos Linux

On your laptop:
1. terraform 1.4+ installed
2. kubectl 1.26+ installed
3. argocd cli 2.6+ installed

Steps to perform:

1. Boot the machine with Talos Linux using an USB stick. It should run in maintenance mode and display an IP. See example below:



2. Now you need to run the terraform code from your laptop. 

Note: The machine and your laptop needs to be on the same network. Make sure that you are able to ping the machine from your laptop on the IP it displays, before running the terraform script.

Remember to update the IP of your machine in your variables.tf file. To run the terraform code, you would need to run the following commands:

```terraform init``` 

then

```terraform plan```

confirm that the plan looks okay and you have the correct resources to be deployed.

Then run:

```terraform apply```

As part of the POC, we are running a single node cluster with one controlplane node which can schedule workloads. In the actual production setup, it would be a good idea to run the cluster with multiple controlplane nodes and worker nodes to maintain quorum.

Once the terraform code is run successfully, you would have a Talos K8s cluster running on the machine bootstrapped with the Talos Linux running underneath. You should also see ArgoCD deployed and running in the argocd namespace. This would enable you to use GitOps to manage your workload.

To download the kubeconfig and talosconfig you would need to run the commands below:

```terraform output -raw kubeconfig > <desired-path-and-filename>```
and 
```terraform output -raw talosconfig > <desired-path-and-filename>```

let's download them under configs folder

Check that kubectl resources are deployed as expected.

```kubectl get pods -n argocd --kubeconfig=configs/kubeconfig```

ArgoCD can be accessed on the link after port forwarding 

```kubectl port-forward svc/argocd-server -n argocd 8080:443 -n argocd --kubeconfig=configs/kubeconfig``` 

and the credentials to access are present in the secret argocd-initial-admin-secret. These credentials need to be updated after the first login, and this would be a manual process. 

You can retrieve the password using the command below:

```kubectl --kubeconfig=configs/kubeconfig -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo```