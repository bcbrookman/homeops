# Platform Layer

This layer provides the platforms which applications and services are deployed on in the [Software Layer](https://bcbrookman.github.io/homeops/software-layer/). It includes for example, guest operating systems, container orchestration platforms (i.e. [Kubernetes](https://kubernetes.io)), and database management systems.

![layers](assets/homeops-layers-pf.svg)

## Platforms

### Kubernetes

[Talos](https://talos.dev) is my distribution of choice in for home infrastructure due to its minimal, hardened footprint, and low opoerational overhead.

The Talos cluster is deployed as virtual machines across each physical [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/overview) server. Both the VMs and Talos are installed and configured using [Terraform](https://www.terraform.io/) (see [Tooling](#tooling) below).

The stable API address required for highly available Talos clusters is provided by the VIP feature included with Talos.

To avoid using more compute resources than necessary, each Talos node currently serves both control plane and worker roles.

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
terraform apply -target=talos_vm[0] -target=talos_vm[1]
```

### Ansible

Much like the [Terraform](https://www.terraform.io/) files in this layer, [Ansible](https://www.ansible.com/) playbooks which apply base configurations are symlinked to the infrastructure layer.

A main.yaml playbook is provided to upgrade installed packages and apply all base configurations. It can be used as follows.

```
cd ./platform-layer/ansible/
ansible-playbook -i inventory/ playbooks/main.yaml -K
```
