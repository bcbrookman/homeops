terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

locals {
  net_cidr_mask = split("/", var.net_cidr_prefix)[1]
}

resource "proxmox_vm_qemu" "talos-vm" {
  # vm_state = "stopped"
  count            = var.nodes
  name             = "${var.name_prefix}0${count.index + 1}"
  target_node      = "pve0${count.index % var.nodes + 1}"
  agent            = 1
  os_type          = "cloud-init"
  qemu_os          = "l26"
  cores            = var.cores
  sockets          = 1
  cpu_type         = "host"
  memory           = var.memory
  scsihw           = "virtio-scsi-pci"
  onboot           = true
  automatic_reboot = false
  disks {
    ide {
      ide0 {
        cdrom {
          iso = var.iso
        }
      }
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size      = var.disk_size
          storage   = "local-lvm"
          replicate = true
        }
      }
    }
  }
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag    = 20
  }
  ipconfig0 = join(",",
    [
      "ip=${cidrhost(var.net_cidr_prefix, var.net_starting_hostnum + count.index)}/${local.net_cidr_mask}",
      "gw=${var.net_gateway_addr}"
    ]
  )
  serial {
    id   = 0
    type = "socket"
  }
  lifecycle {
    # prevent_destroy = true
    ignore_changes = [
      clone,
      full_clone,
      network,
    ]
  }
}
