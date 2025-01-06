# Platform Layer

This layer provides the platforms which applications and services are deployed on in the [Software Layer](https://bcbrookman.github.io/homeops/software-layer/). It includes for example, guest operating systems, container orchestration platforms (i.e. [Kubernetes](https://kubernetes.io)), and database management systems.

![layers](assets/homeops-layers-pf.svg)

## Platforms

### Kubernetes

[K3s](https://k3s.io) is currently the distribution used in my home infrastructure for its small footprint and simple deployment.

The K3s cluster is deployed on Debian virtual machines across each physical [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) server. The virtual machines for the cluster are provisioned using [Terraform](https://www.terraform.io/), and K3s is then installed and configured using Ansible (see [Tooling](#tooling) below).

The stable API endpoint IP address required for highly available K3s clusters is provided by an [HAProxy](https://www.haproxy.org/) load balancer installed on the WAN [pfSense](https://www.pfsense.org/) firewalls. Since the firewalls are already configured as highly available, the HAProxy servers installed on them are also highly available with no extra configuration.

To avoid using more compute resources than necessary, each K3s node currently serves both K3s server (control plane) and K3s agent (worker) roles. However, this strategy may change in the future.

### PostgreSQL

[PostgreSQL](https://www.postgresql.org/) is currently deployed on a single [LXC container]https://linuxcontainers.org/. In the future, this will be expanded with a replica on each physical [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) server and high-availability components.

## Tooling

### Terraform

As with the infrastructure layer, virtual machines are initially provisioned on [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) using [Terraform](https://www.terraform.io/). The base Terraform configuration files are symlinked to the infrastructure layer.

VMs can be provisioned using `terraform apply`.

```
cd ./platform-layer/terraform
terraform apply
```

The `-target` option can also be added to limit the scope of the `apply`. This can be useful when needing to apply changes to a subset of resource at a time. For example, when changing K8s nodes.

```
cd ./platform-layer/terraform
terraform apply -target=-k3s-prod[0] -target=k3s-prod[1]
```

### Ansible

Much like the [Terraform](https://www.terraform.io/) files in this layer, [Ansible](https://www.ansible.com/) playbooks which apply base configurations are symlinked to the infrastructure layer.

A main.yaml playbook is provided to upgrade installed packages and apply all base configurations. It can be used against staging environment hosts as follows.

```
cd ./platform-layer/ansible/
ansible-playbook -i inventory/ playbooks/main.yaml -K
```

To then configure a K3s cluster on the nodes, use the playbook provided by k3s-ansible.

```
ansible-playbook -i inventory/ k3s-ansible/site.yml -K
```
