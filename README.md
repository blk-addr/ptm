# Proxmox Management via Terraform

This documentation outlines the setup and management of Proxmox Virtual Environment (PVE) using Terraform for infrastructure as code (IaC). By following these steps, you can automate the provisioning, configuration, and management of your Proxmox servers and virtual machines.

## Prerequisites

- **Proxmox VE** installed and accessible via network.
- **Proxmox Cloud-Init Template** ready, see [Proxmox provider instructions here](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/cloud-init%20getting%20started.md) and [cloud-init module docs here](https://cloudinit.readthedocs.io/en/latest/reference/modules.html)
- **Terraform** installed on your local development environment, [instructions here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Initial Setup

**Note:** Initial setup is done following the steps for the Terraform Provider for Proxmox here: [Terraform Proxmox Provider Docs](https://registry.terraform.io/providers/Terraform-for-Proxmox/proxmox/latest/docs)

### 1. Create the Terraform User

First, we need to create a user with specific privileges for Terraform to interact with Proxmox from the Proxmox node shell:
```bash
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
pveum user add terraform-prov@pve --password <password>
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

### 2. Create an API Token

- Navigate to your Proxmox GUI: **Datacenter > Permissions > API Tokens**
- Add a new API Token for `terraform-prov@pve`
- Store the token ID and secret securely.

### 3. Export API Token Info as Environment Variables

Before running Terraform, set your API token information as Terraform-compatible (prefixed with `TF_VAR_`) environment variables:

```bash
export TF_VAR_pm_api_token_id='terraform-prov@pve!mytoken'
export TF_VAR_pm_api_token_secret='<token-secret>'
```

### 4. Setup Terraform Configuration
In your Terraform workspace, create or edit main.tf with the following content:
```hcl
provider "proxmox" {
  pm_api_url      = "https://192.168.1.209:8006/api2/json"
  pm_api_token_id         = var.pm_api_token_id
  pm_api_token_secret     = var.pm_api_token_secret
  pm_debug        = true # Set to false once debugging is done
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
}
```
... and create a versions.tf in the same directory with provider info:
```hcl
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}
```

#### Setting up Cloud-Init VM
This must be done manually from the Proxmox terminal. Instructions [from Proxmox here](https://pve.proxmox.com/wiki/Cloud-Init_Support) and [from the Terraform provider here](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/guides/cloud-init%20getting%20started.md)
```bash
# download the image
wget 'https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img'

# create a new VM
qm create 9000 --name ubuntu-noble-cloudinit

# import the downloaded disk to the local-lvm storage, attaching it as a SCSI drive; must use absolute file path to the image0
qm set 9000 --scsi0 local-lvm:0,import-from=/root/noble-server-cloudimg-amd64.img

# create a template from the new VM
qm template 9000
```

For the IaC Host, you will want something like this as your snippet:  
(See [cloud-init modules](https://cloudinit.readthedocs.io/en/latest/reference/modules.html#mod-cc-ansible))

```yaml /var/lib/vz/snippets/iac-tools.yml
#cloud-config
apt:
  preserve_sources_list: true
  sources:
    source1:
      keyid: 798AEC654E5C15428C8E42EEAA16FCBCA621E701 # https://stackoverflow.com/a/72629066
      keyserver: https://apt.releases.hashicorp.com/gpg
      source: deb [signed-by=$KEY_FILE] https://apt.releases.hashicorp.com $RELEASE main
      append: true
package_reboot_if_required: true
package_update: true
package_upgrade: true
packages:
  - apt:
    - gnupg
    - software-properties-common
    - qemu-guest-agent
    - terraform
    - nfs-common
ansible:
  package_name: ansible-core
  install_method: distro # pip option appears broken https://github.com/canonical/cloud-init/issues/5720
runcmd:
  - systemctl enable qemu-guest-agent # Fails to start manually; interwebs say to manually STOP the VM completely, wait, then start the VM
mounts:
  - ["192.168.1.130:/mnt/vol_01/iac", "/mnt/iac/", "nfs4", "rw,x-systemd.automount", "0", "0"]
power_state:
  delay: now
  mode: reboot
  message: Cloud-init complete, rebooting machine
  condition: true
```

Ensure a default user snippet is available on the Proxmox server
```bash
tee /var/lib/vz/snippets/default-user.yml <<EOF
#cloud-config
users:
  - name: thisguy
    plain_text_passwd: <supersecure>
    gecos: Such a cool guy!
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, adm
    shell: /bin/bash
    lock_passwd: false
  - name: iac
    gecos: These guys do all the work
    groups: users, adm
    shell: /bin/bash
    lock_passwd: true
chpasswd:
  expire: false
ssh_pwauth: true
EOF
```

At this point, run `terraform apply`. If all goes well, you have an IaC host to create and manage all of your future Proxmox hosts!

