provider "proxmox" {
  pm_api_url      = "https://192.168.1.209:8006/api2/json"
  pm_api_token_id         = var.pm_api_token_id
  pm_api_token_secret     = var.pm_api_token_secret
  pm_debug        = true # Set to false once debugging is done
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

# Sets up the IaC server on Proxmox
module "iac-host" {
  source   = "../../modules/ubuntu-template"
  vm_name  = "iac-host"
  memory   = 8192
  snippets = [ "user=local:snippets/default-user.yml", "vendor=local:snippets/iac-tools.yml" ]
}

# TODO: Set up Proxmox TLS
#   - https://pve.proxmox.com/wiki/Certificate_Management
# TODO: set hostname in hostname file
# TODO: get rundeck behind a proxy with TLS 
#   - https://blog.walnuthomelab.com/posts/2022/june/024-rundeck-install/
#   - https://docs.nginx.com/nginx/admin-guide/installing-nginx/installing-nginx-open-source/#installing-a-prebuilt-debian-package-from-the-official-nginx-repository
# TODO: put snippets in this repo, upload to PVE
#   - https://stackoverflow.com/questions/78628828/unable-to-upload-cloudinit-snippets-via-ssh
