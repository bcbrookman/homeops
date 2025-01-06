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

The network plugin used in the cluster is the default [Flannel](https://github.com/flannel-io/flannel) included with [K3s](https://k3s.io). Besides not directly supporting network policies, it just works and I've never had to think about it much.

For load balancer services, K3s does include [ServiceLB](https://github.com/k3s-io/klipper-lb) (formerly Klipper). However, it works by using host ports and does not allow for stable load balancer IPs. It can work well for simple use-cases, but does not fit my needs. I disable it and deploy [MetalLB](https://github.com/k3s-io/klipper-lb) in L2 mode instead.

For Ingress/Gateway API controller, I use [Traefik](https://traefik.io/traefik/) which is also included with K3s.

### Persistent Storage

[Longhorn](https://longhorn.io/) provides the bulk of the persistent storage used by containers. It provides replicated highly-available block storage and NFS volumes for my containers. It also automatically backs up volumes to my external [Synology NAS](https://www.synology.com/en-us/products/DS920+).

In addition to Longhorn, a few NFS volumes are also mapped directly to my external Synology NAS. These volumes are for media and user files that require large capacity, or aren't directly related to the application's persistence.

## Tooling

### Flux

[Flux](https://fluxcd.io/) is used to implement [GitOps](https://www.weave.works/technologies/gitops/) in my cluster. Flux reconciles the Kubernetes resources defined as manifests and Helm charts within this repository with the actual resources deployed in the cluster. Using Flux Image Automation, it also automatically updates manifests with new image versions, and triggers pull requests (with the help of a GitHub Actions workflow) to include them in the repository.
