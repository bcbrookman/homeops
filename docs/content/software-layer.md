# Software Layer

This layer provides the applications and services that users interact with. It includes deployed applications, along with their definitions and configurations.

![layers](assets/homeops-layers-sw.svg)

## Apps & Services

All apps and services deployed in the Software Layer are currently deployed on Kubernetes. This includes:

  - [GitHub Actions Runner Controller (ARC)](https://github.com/actions/actions-runner-controller)
  - [Home Assistant](https://www.home-assistant.io/)
  - [Homer](https://github.com/bastienwirtz/homer)
  - [Kube Prometheus Stack](https://github.com/prometheus-operator/kube-prometheus)
  - [Mealie](https://mealie.io/)
  - [Pi-hole](https://pi-hole.net/)
  - [Plex Media Server](https://www.plex.tv/)
  - [Tautulli](https://tautulli.com/)
  - [Unifi Network](https://ui.com/)
  - [Uptime Kuma](https://github.com/louislam/uptime-kuma)

## Kubernetes Infrastructure

### Networking

The network plugin used in the cluster is [Cilium](https://cilium.io/).

While Cilium does offer an [LB IPAM](https://docs.cilium.io/en/stable/network/lb-ipam/) feature to support `loadBalancer` services, it doesn't currently support the `externalTrafficPolicy: Local` option in L2 Aware LB mode (see [limitations](https://docs.cilium.io/en/stable/network/l2-announcements/#limitations)). For that reason, I use [MetalLB](https://metallb.io) in L2 mode instead.

I do, however, use the built-in Ingress features within Cilium.

### Persistent Storage

[Longhorn](https://longhorn.io/) provides the bulk of the persistent storage used by containers. It provides replicated highly-available block storage and NFS volumes for my containers. It also automatically backs up volumes to my external [Synology NAS](https://www.synology.com/en-us/products/DS920+).

In addition to Longhorn, a few NFS volumes are also mapped directly to my external Synology NAS. These volumes are for media and user files that require large capacity, or aren't directly related to the application's persistence.

## Tooling

### Flux

[Flux](https://fluxcd.io/) is used to implement [GitOps](https://www.weave.works/technologies/gitops/) in my cluster. Flux reconciles the Kubernetes resources defined as manifests and Helm charts within this repository with the actual resources deployed in the cluster. Using Flux Image Automation, it also automatically updates manifests with new image versions, and triggers pull requests (with the help of a GitHub Actions workflow) to include them in the repository.
