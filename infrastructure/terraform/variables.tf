variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  default = "y0__xDR2fYlGMHdEyDX48zUEvpPpOAMxHFOIlqJBiQo2ojarq9c"
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1g4u08kmhkhn7n929cv"
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default     = "b1gsjli4q63fcdrigti2"
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

variable "lamp_image_id" {
  description = "Yandex Cloud Image ID for LAMP VM template"
  type        = string
  default     = "fd827b91d99psvq5fjit"
}

variable "yc_zone" {
  description = "Zone"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = "/home/wrcs/.ssh/id_ed25519.pub"
}

variable "bucket_name" {
  description = "Globally unique Object Storage bucket name"
  type        = string
  default     = "wrcs-netology-lb-20260305"
}

variable "bucket_object_key" {
  description = "Object key for uploaded image"
  type        = string
  default     = "lamp-image.png"
}

variable "bucket_image_source" {
  description = "Path to image file uploaded to Object Storage"
  type        = string
  default     = "../../images/terraform apply_3_scrin_YC_VM.png"
}
