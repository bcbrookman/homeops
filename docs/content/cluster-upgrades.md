# Cluster Upgrades

## Upgrading Talos

1. Check the current Talos cluster info and version.

    ```shell
    talosctl get info
    talosctl get version
    ```

1. Review the new features, support matrix, and upgrade steps in the [Talos Docs](https://docs.siderolabs.com/talos/).

    The following links are for Talos v1.11:

    - [What's new in Talos](https://docs.siderolabs.com/talos/v1.11/getting-started/what's-new-in-talos)
    - [Support Matrix](https://docs.siderolabs.com/talos/v1.11/getting-started/support-matrix)
    - [Upgrading Talos](https://docs.siderolabs.com/talos/v1.11/configure-your-talos-cluster/lifecycle-management/upgrading-talos#upgrading-talos-linux)
    - [Talos Releases](https://github.com/siderolabs/talos/releases)

1. Locally update the value of `local.version` in `platform-layer/terraform/talos-cluster.tf` with the appropriate target version.

    ```hcl
    locals {
        ...
        talos_install_version = "X.X.X"
        ...
    }
    ```

    !!! Note

        Talos requires step-upgrading to the latest patch of the current minor release before the latest patch of the next minor version. Upgrading from v1.10.2 to v.1.11.3, for example, would require first upgrading to v1.10.7 before upgrading to v1.11.3.


1. Generate and display the new Terraform outputs.

    ```shell
    cd platform-layer/terraform/
    TF_WORKSPACE=homeops-pf-layer terraform init
    TF_WORKSPACE=homeops-pf-layer terraform plan -refresh-only
    ```

1. Upgrade one of the Talos nodes with the new installer image from the Terraform output.

    ```shell
    talosctl upgrade \
     --preserve \
     --image 'factory.talos.dev/nocloud-installer/88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b:v1.10.7' \
     --nodes '192.168.20.X'
    ```

1. Repeat step 5 for each node in the cluster.
1. Repeat steps 1-6, step-upgrading until the final target version is reached.
1. Run `terraform apply` to view and reconcile any changes.

    ```shell
    TF_WORKSPACE=homeops-pf-layer terraform apply
    ```

1. Commit, push, and merge the changes.

## Replacing nodes

Should the need arise to remove a node from a Talos cluster, the following steps will ensure it is removed cleanly. These steps are also partially described in [Scale down a Talos cluster](https://docs.siderolabs.com/talos/v1.9/deploy-and-manage-workloads/scaling-down).


1. Review the current cluster info and nodes.

    ```shell
    talosctl get info
    talosctl etcd status
    kubectl get nodes -o wide
    ```

1. Ensure all CNPG clusters have at least one replica on other nodes.

    ```shell
    kubectl get clusters -A
    kubectl get pods -l cnpg.io/cluster -A -o wide
    ```

1. Reset the Talos node.

    ```shell
    talosctl -n <NODE-IP-TO-REMOVE> reset
    ```

1. Remove the node from the Kubernetes cluster.

    ```shell
    kubectl delete node <NODE-NAME-TO-REMOVE>
    ```

1. Validate the node was fully removed.

    ```shell
    talosctl get members
    talosctl etcd members
    kubectl get nodes -o wide
    ```

    !!! note

        Since your talosconfig still contains the removed node, expect a connection error for the `talosctl` commands. However, the output from the other nodes should no longer include the removed node.

1. Install/provision the replacement Talos node.
1. Delete the removed node's `talos_machine_configuration_apply` from Terraform state.

    This is required because the resource only applies machine configurations. Terraform state; it does not compare the defined configs with the current configs.

    ```shell
    cd platform-layer/terraform/
    TF_WORKSPACE=homeops-pf-layer terraform state rm 'module.talos_cluster.talos_machine_configuration_apply.controlplane["<NODE-IP-TO-REMOVE>"]'
    ```

1. If needed, modify Terraform to account for the new nodes details.

1. Run `terraform apply` locally to apply the changes.

    ```shell
    TF_WORKSPACE=homeops-pf-layer terraform init
    TF_WORKSPACE=homeops-pf-layer terraform apply
    ```

1. Delete any CNPG instance PVCs waiting on the removed node

    First, check for failed CNPG cluster instances and PVCs associated with the removed node:

    ```shell
    kubectl get clusters -A -o json | jq '.items[]|{namespace:.metadata.namespace,cluster:.metadata.name,"failed-instances":.status.instancesStatus.failed}'
    kubectl get pvc -l "cnpg.io/cluster" -A -o json | jq '.items[].metadata|{pvc:"\(.namespace)/\(.name)","pvc-node":.annotations."volume.kubernetes.io/selected-node","cnpg-cluster":.labels."cnpg.io/cluster","cnpg-instance":.labels."cnpg.io/instanceName"}'
    ```

    Then, destroy any cluster instances associated with the removed node:

    ```shell
    kubectl cnpg destroy <CLUSTER> <INSTANCE> -n <NAMESPACE>
    kubectl cnpg destroy <CLUSTER> <INSTANCE> -n <NAMESPACE>
    ...
    kubectl cnpg destroy <CLUSTER> <INSTANCE> -n <NAMESPACE>
    ```
