# Cluster Upgrades

## Upgrading Talos

1. Check the current Talos cluster info and version

    ```shell
    talosctl get info
    talosctl get version
    ```

2. Review the new features, support matrix, and upgrade steps in the [Talos Docs](https://docs.siderolabs.com/talos/).

   The following links are for Talos v1.11:

   - [What's new in Talos](https://docs.siderolabs.com/talos/v1.11/getting-started/what's-new-in-talos)
   - [Support Matrix](https://docs.siderolabs.com/talos/v1.11/getting-started/support-matrix)
   - [Upgrading Talos](https://docs.siderolabs.com/talos/v1.11/configure-your-talos-cluster/lifecycle-management/upgrading-talos#upgrading-talos-linux)
   - [Talos Releases](https://github.com/siderolabs/talos/releases)

3. Locally update the value of `local.version` in `platform-layer/terraform/talos-cluster.tf` with the appropriate target version.

    ```hcl
    locals {
        ...
        talos_install_version = "X.X.X"
        ...
    }
    ```

    !!! Note

        Talos requires step-upgrading to the latest patch of the current minor release before the latest patch of the next minor version. Upgrading from v1.10.2 to v.1.11.3, for example, would require first upgrading to v1.10.7 before upgrading to v1.11.3.


4. Generate and display the new Terraform outputs

    ```shell
    cd platform-layer/terraform/
    TF_WORKSPACE=homeops-pf-layer terraform init
    TF_WORKSPACE=homeops-pf-layer terraform plan -refresh-only
    ```

5. Upgrade one of the Talos nodes with the new installer image from the Terraform output

    ```shell
    talosctl upgrade \
     --preserve \
     --image 'factory.talos.dev/nocloud-installer/88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b:v1.10.7' \
     --nodes '192.168.20.X'
    ```

6. Repeat step 5 for each node in the cluster
7. Repeat steps 1-6, step-upgrading until the final target version is reached
8. Run `terraform apply` to view and reconcile any changes

    ```shell
    TF_WORKSPACE=homeops-pf-layer terraform apply
    ```

9. Commit, push, and merge the changes
