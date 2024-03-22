# Resilient Edge Toolstack "RET"

## Information:
There are 2 Git repos:
1. Containing the infrastructure related provisioning part

2. Containing the GitOps code (the applications in K8s cluster) 

#### Prerequisites:
An USB stick burned with ISO image of Talos Linux https://github.com/siderolabs/talos/releases/

On your laptop:
1. docker installed
2. kubectl 1.26+ installed

## Gitops Repo setup

The repository for your bootstrapped gitops repo is located at `playbooks/roles/argocd-provision/manifests/argocd-apps.yaml`

## Installation

Steps to perform:

* Boot the machine with Talos Linux using an USB stick. It should run in maintenance mode and display an IP.

* Check the IP address of the machine and update the `playbooks/roles/talos-provision/vars/main.yml` file.

* Make sure to change the value of the variable [controlplane_ips](playbooks/roles/talos-provision/vars/main.yml) to the IP of the host talos is being deployed to, multiple hosts are currently not supported.

* Run the ansible-playbook in the docker container

> Note: If talosctl apply-config fails with the error that the defined install_disk doesn't exist, run ```talosctl -n <controlplane_ip> disks --insecure``` to see what disks are available, see docs https://www.talos.dev/v1.6/introduction/getting-started/#modifying-the-machine-configs standard predefined in the playbook is /dev/sda but can differ.

> Note: Your host & the host you're deploying talos on needs to be able to reach eachother. 

```docker run -ti -v ${PWD}:/k8s-edge-infra -w /k8s-edge-infra ghcr.io/eficode-academy/edgek8s-provision:latest ansible-playbook playbooks/edgek8s-complete-provision.yml```

> :bulb: You cloud add a userID that is equivalent to the user that is running the ansible-playbook in the docker container, this is to avoid permission issues when mounting the volume in the docker container.

Make sure that the path to the repo is correct in the volume mounted, change the left part (by the -v flag in the docker command) of the path to match the path to the repo on your localhost.

Once the ansible-playbook has completed you have a Talos K8s cluster running on the machine bootstrapped with Talos Linux running underneath. You should also see ArgoCD deployed and running in the argocd namespace. This enables the use of GitOps to manage your workload/applications from here.

## Post Installation

The kubeconfig & talosconfig are available under ```talos_output/``` after deployment

Check that kubectl resources are deployed as expected.

```kubectl get pods -A --kubeconfig=talos_output/kubeconfig```

ArgoCD can be accessed on the link after port forwarding 

```kubectl port-forward svc/argocd-server -n argocd 8080:443 --kubeconfig=talos_outptu/kubeconfig``` 

The credentials to access the ArgoCD GUI are present in the secret argocd-initial-admin-secret. These credentials need to be updated after the first login, and this would be a manual process. In a production environment the point is to never have to access the ArgoCD UI/CLI and instead have everything managed through in this case the https://github.com/eficode-academy/k8s-edge-gitops repo.

You can retrieve the password using the command below:

```kubectl --kubeconfig=talos_output/kubeconfig -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo```