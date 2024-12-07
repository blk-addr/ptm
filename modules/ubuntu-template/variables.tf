variable "vm_id" {
    description = "The ID of the VM to create. Defaults to 0, which uses the next available."
    type        = number
    default     = 0
}

variable "vm_name" {
  description = "The name of the VM to create"
  type        = string
}

variable "target_node" {
  description = "The Proxmox node to deploy the VM on"
  type        = string
  default     = "pve"
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = string
  default     = "16G"
}

variable "network_bridge" {
  description = "The name of the network bridge to connect the VM to"
  type        = string
  default     = "vmbr0"
}

variable "network_model" {
  description = "The model of the network bridge to connect the VM to"
  type        = string
  default     = "virtio"
}

# variable "ip_address" {
#  description = "The IP address to assign to the VM"
#  type        = string
# }

# variable "gateway" {
#   description = "The gateway for the VM's network"
#   type        = string
# }

variable "nameserver" {
  description = "DNS server"
  type        = string
  default     = "192.168.1.4" #My pihole
}

variable "ssh_public_key" {
  description = "The SSH public key to add to the VM; newline delimited if there are multiple"
  type        = string
  default     = ""
}

variable "snippets" {
    type = list(string)
    default = [ "user=local:snippets/default-user.yml", "vendor=local:snippets/qemu-guest-agent.yml" ]
  
}