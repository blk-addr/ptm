provider "proxmox" {
  pm_api_url      = "https://192.168.1.209:8006/api2/json"
  pm_api_token_id         = var.pm_api_token_id
  pm_api_token_secret     = var.pm_api_token_secret
  pm_debug        = true # Set to false once debugging is done
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

# Sets up the IaC server on Proxmox
module "iac-host" {
  source = "../../modules/ubuntu-template"
  vm_name = "iac-host"
  snippets = [ "user=local:snippets/default-user.yml", "vendor=local:snippets/iac-tools.yml" ]
}
