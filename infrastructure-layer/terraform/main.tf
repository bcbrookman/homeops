terraform {
  cloud {
    organization = "bcbrookman"
    workspaces {
      tags = ["homeops"]
    }
  }
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}

data "sops_file" "tfvars" {
  source_file = "tfvars.yaml"
}

variable "pm_api_url" {
  sensitive = true
  default   = "https://pve:8006/api2/json"
}

variable "pm_api_token_id" {
  sensitive = true
  default   = "user@pam!token"
}

variable "pm_api_token_secret" {
  sensitive = true
  default   = "token"
}

variable "sshkeys" {
  sensitive = true
  default   = "ssh-public-key"
}

provider "proxmox" {
  pm_api_url          = data.sops_file.tfvars.data["pm_api_url"]
  pm_api_token_id     = data.sops_file.tfvars.data["pm_api_token_id"]
  pm_api_token_secret = data.sops_file.tfvars.data["pm_api_token_secret"]
  pm_tls_insecure     = true
}
