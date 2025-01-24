variable "location" {
  type    = string
  default = "uksouth"
}

variable "vm_admin_username" {
  type    = string
  default = "louisadmin"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "trusted_ip" {
  type      = string
  sensitive = true
  description = "Public IP address (with /32) allowed to SSH in."
}
