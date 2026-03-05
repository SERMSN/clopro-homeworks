output "nat_public_ip" {
  value = yandex_compute_instance.nat.network_interface.0.nat_ip_address
}

output "nat_internal_ip" {
  value = yandex_compute_instance.nat.network_interface.0.ip_address
}

output "public_vm_public_ip" {
  value = yandex_compute_instance.public_vm.network_interface.0.nat_ip_address
}

output "public_vm_internal_ip" {
  value = yandex_compute_instance.public_vm.network_interface.0.ip_address
}

output "private_vm_internal_ip" {
  value = yandex_compute_instance.private_vm.network_interface.0.ip_address
}

output "task2_bucket_name" {
  value = yandex_storage_bucket.images.bucket
}

output "task2_bucket_image_url" {
  value = local.bucket_image_url
}

output "task2_instance_group_id" {
  value = yandex_compute_instance_group.lamp_group.id
}

output "task2_nlb_public_ip" {
  value = one(flatten([
    for l in yandex_lb_network_load_balancer.lamp_nlb.listener : [
      for a in l.external_address_spec : a.address
    ]
  ]))
}

output "task2_nlb_url" {
  value = "http://${one(flatten([
    for l in yandex_lb_network_load_balancer.lamp_nlb.listener : [
      for a in l.external_address_spec : a.address
    ]
  ]))}"
}
