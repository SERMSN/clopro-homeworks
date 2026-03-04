variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  default     = "y0__************"
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1g4u*************"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default     = "b1gsj*************"
}

variable "yc_image_id" {
  description = "Yandex Cloud Image ID for regular VMs"
  type        = string
  default     = "fd8vsghfu10ev5gdatkh"
}

variable "nat_image_id" {
  description = "Yandex Cloud Image ID for NAT instance"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}

variable "yc_zone" {
  description = "Zone"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = "/home/*****/.ssh/id_ed******.pub"
}
