# Platform Layer

This layer provides the platforms which applications and services are deployed on in the [Software Layer](https://bcbrookman.github.io/homeops/software-layer/). It includes for example, guest operating systems, container orchestration platforms (i.e. [Kubernetes](https://kubernetes.io)), and database management systems.

![layers](assets/homeops-layers-pf.svg)

## Platforms

### Kubernetes

[Talos](https://talos.dev) is my distribution of choice in for home infrastructure due to its minimal, hardened footprint, and low opoerational overhead.

The Talos cluster is deployed on bare-metal small form factor machines. Talos is bootstrapped and configured using [Terraform](https://www.terraform.io/).

The stable API address required for highly available Talos clusters is provided by the VIP feature included with Talos.

To avoid using more compute resources than necessary, each Talos node currently serves both control plane and worker roles.
