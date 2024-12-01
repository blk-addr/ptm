output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_vm_qemu.virtual_machine.id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_vm_qemu.virtual_machine.name
}

output "vm_ip" {
  description = "IP address of the VM"
  value       = proxmox_vm_qemu.virtual_machine.default_ipv4_address
}

output "vm_network" {
  description = "Network configuration of the VM"
  value       = proxmox_vm_qemu.virtual_machine.network
}