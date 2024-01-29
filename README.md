# k8s-talos-ansible

## Information:
There are 2 Git repos:
1. Containing the infrastructure related provisioning part

2. Containing the GitOps code (the applications in K8s cluster) 

#### Prerequisites:
An USB stick burned with ISO image of Talos Linux https://github.com/siderolabs/talos/releases/

On your laptop:
1. docker installed
2. kubectl 1.26+ installed
3. argocd cli 2.6+ installed

Steps to perform:

1. Boot the machine with Talos Linux using an USB stick. It should run in maintenance mode and display an IP.

2. Run the ansible-playbook in the docker container

Build the Dockerfile provided locally, this docker image is to be used as a provision image, the dot at the end is important

```docker build -t eficode-academy/edgek8s-provision:latest .``` 

Note: If talosctl apply-config fails with the error that the defined install_disk doesn't exist, run ```talosctl -n <controlplane_ip> disks --insecure``` to see what disks are available, see docs https://www.talos.dev/v1.6/introduction/getting-started/#modifying-the-machine-configs standard predefined in the playbook is /dev/sda but can differ.

Note: Your host & the host you're deploying talos on needs to be able to reach eachother. 

Make sure to change the value of the variable ```controlplane_ips``` (playbooks/roles/talos-provision/vars/main.yml) to the IP of the host talos is being deployed to, multiple hosts are currently not supported.

```docker run -it -v /Users/danielr/work/k8s-edge-infra:/k8s-edge-infra ghcr.io/eficode-academy/edgek8s-provision:latest /bin/sh -c "cd k8s-edge-infra && ansible-playbook playbooks/edgek8s-complete-provision.yml"```

Make sure that the path to the repo is correct in the volume mounted, change the left part (by the -v flag in the docker command) of the path to match the path to the repo on your localhost.

As part of the POC, we are running a single node cluster with one controlplane node which can schedule workloads. In the actual production setup, it would be a good idea to run the cluster with multiple controlplane nodes and worker nodes to maintain quorum.

Once the ansible-playbook has completed you have a Talos K8s cluster running on the machine bootstrapped with Talos Linux running underneath. You should also see ArgoCD deployed and running in the argocd namespace. This enables the use of GitOps to manage your workload/applications.

In the argo-provision role (```playbooks/roles/argo-provision/manifests```) there is an argocd application manifest which points to a gitops repository which contains a bunch of applications which will be deployed by argoCD automatically. This application deploys all manifests that are available in that repo https://github.com/eficode-academy/k8s-edge-gitops It could be customized further to fit your needs. The whole point is that everything should be managed from the gitops repository once the base infrastructure is in place.

The kubeconfig & talosconfig are available under ```talos_output/``` after deployment

Check that kubectl resources are deployed as expected.

```kubectl get pods -A --kubeconfig=talos_output/kubeconfig```

ArgoCD can be accessed on the link after port forwarding 

```kubectl port-forward svc/argocd-server -n argocd 8080:443 --kubeconfig=talos_outptu/kubeconfig``` 

The credentials to access the ArgoCD GUI are present in the secret argocd-initial-admin-secret. These credentials need to be updated after the first login, and this would be a manual process. In a production environment the point is to never have to access the ArgoCD UI/CLI and instead have everything managed through in this case the https://github.com/eficode-academy/k8s-edge-gitops repo.

You can retrieve the password using the command below:

```kubectl --kubeconfig=talos_output/kubeconfig -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo```