terraform {
  cloud {
    organization = "bcbrookman"
    workspaces {
      tags = ["homeops"]
    }
  }
  required_providers {
    sops = {
      source = "carlpett/sops"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.0"
    }
  }
}
