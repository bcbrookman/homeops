# HomeOps

This repository contains my personal home infrastructure, defined and deployed as code using [IaC](https://en.wikipedia.org/wiki/Infrastructure_as_code), and [GitOps](https://www.weave.works/technologies/gitops/) practices where possible.

## Goals

My home infrastructure helps support much of what I do everyday and is designed with the following goals in mind:

- High service uptime
- High fault tolerance
- Best practice security
- Privacy by design
- Efficient resource utilization
- Low power, noise, and space

## Layers

My home infrastructure is broken up into layers which very loosely align with the concepts of [IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service), [PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service), and [SaaS](https://en.wikipedia.org/wiki/Software_as_a_service). Modularizing the infrastructure in this way helps me isolate dependencies, and avoid deployment problems.

![](https://github.com/bcbrookman/homeops/raw/main/docs/content/assets/homeops-layers-all.svg)

- The [Software Layer](https://bcbrookman.github.io/homeops/software-layer/) provides the applications and services that users interact with. It includes deployed applications, along with their definitions and configurations.
- The [Platform Layer](https://bcbrookman.github.io/homeops/platform-layer/) provides the platforms which applications and services are deployed on in the Software Layer. It includes for example, guest operating systems, container orchestration platforms (i.e. [Kubernetes](https://kubernetes.io)), and database management systems.
- The [Infrastructure Layer](https://bcbrookman.github.io/homeops/infrastructure-layer/) provides the basic networking, storage, and compute resources used by the Platform Layer. It includes physical hardware, hypervisors, and other infrastructure components.

Click on the links in the above descriptions for more detail on each layer.

## Changelog

See [commit history](https://github.com/bcbrookman/homeops/commits/main)
