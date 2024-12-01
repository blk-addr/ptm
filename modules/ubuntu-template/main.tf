resource "proxmox_vm_qemu" "virtual_machine" {
  vmid        = var.vm_id
  name        = var.vm_name
  target_node = var.target_node
  agent       = 1
  cores       = var.cpu_cores
  memory      = var.memory
  boot        = "order=scsi0" # has to be the same as the OS disk of the template
  clone       = "ubuntu-noble-cloudinit" # The name of the template
  scsihw      = "virtio-scsi-single"
  vm_state    = "running"
  automatic_reboot = true

  # Cloud-Init configuration
  cicustom   = join(",", var.snippets)
  ciupgrade  = true
  nameserver = var.nameserver
  ipconfig0  = "ip=dhcp"
  skip_ipv6  = true
  sshkeys    = var.ssh_public_key

  # Most cloud-init images require a serial device for their display
#   serial {
#     id = 0
#   }

  disks {
    scsi {
      scsi0 {
        # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
        disk {
          storage = "local-lvm"
          # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
          size    = var.disk_size 
        }
      }
    }
    ide {
      # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id = 0
    bridge = var.network_bridge
    model  = var.network_model
  }
}