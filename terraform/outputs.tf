output "public_ip" {
  description = "Public IP of the VM"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}