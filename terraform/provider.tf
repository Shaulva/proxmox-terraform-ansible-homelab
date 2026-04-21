terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "https://192.168.1.10:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "TOKEN_SECRET"
  insecure            = true
}
