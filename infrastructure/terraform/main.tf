###############################################################################
## ОСНОВНЫЕ ПЕРЕМЕННЫЕ И ПРОВАЙДЕР
###############################################################################
# Настройки провайдера и переменные определены в отдельных файлах:
# - providers.tf: настройка Yandex Cloud провайдера
# - variables.tf: все переменные (токены, ID облака, папки, образов и т.д.)
# - outputs.tf: вывод IP адресов созданных ресурсов

###############################################################################
## 1. СЕТЕВАЯ ИНФРАСТРУКТУРА
###############################################################################

# Основная VPC сеть
resource "yandex_vpc_network" "network" {
  name = "netology-network"
}

# Публичная подсеть
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Таблица маршрутизации для приватной подсети
resource "yandex_vpc_route_table" "private_rt" {
  name       = "private-rt"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

# Приватная подсеть
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

###############################################################################
## 2. ГРУППЫ БЕЗОПАСНОСТИ
###############################################################################

# Публичная ВМ (доступ по SSH из интернета)
resource "yandex_vpc_security_group" "public_sg" {
  name       = "public-vm-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Приватная ВМ (доступ по SSH только из публичной подсети)
resource "yandex_vpc_security_group" "private_sg" {
  name       = "private-vm-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["192.168.10.0/24"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# NAT-инстанс (принимает трафик из приватной подсети)
resource "yandex_vpc_security_group" "nat_sg" {
  name       = "nat-instance-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["192.168.20.0/24"]
  }

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################################################################
## 3. ВЫЧИСЛИТЕЛЬНЫЕ РЕСУРСЫ (ВИРТУАЛЬНЫЕ МАШИНЫ)
###############################################################################

# NAT-инстанс в публичной подсети
resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  hostname    = "nat-instance"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    ip_address         = "192.168.10.254"
    nat                = true
    security_group_ids = [yandex_vpc_security_group.nat_sg.id]
  }

  metadata = {
    ssh-keys = "wrcs:${file(var.ssh_public_key)}"
  }
}

# Публичная ВМ с публичным IP
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  hostname    = "public-vm"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.public_sg.id]
  }

  metadata = {
    ssh-keys = "wrcs:${file(var.ssh_public_key)}"
  }
}

# Приватная ВМ без публичного IP
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  hostname    = "private-vm"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.yc_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.private_sg.id]
  }

  metadata = {
    ssh-keys = "wrcs:${file(var.ssh_public_key)}"
  }
}

###############################################################################
## 4. ДЗ2: OBJECT STORAGE + INSTANCE GROUP + NLB
###############################################################################

resource "yandex_iam_service_account" "lb_sa" {
  name        = "lb-ig-sa"
  description = "Service account for instance group and object storage"
}

resource "yandex_resourcemanager_folder_iam_member" "lb_sa_editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.lb_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "lb_sa_storage_admin" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.lb_sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "lb_sa_key" {
  service_account_id = yandex_iam_service_account.lb_sa.id
  description        = "Static access key for Object Storage"
}

resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "task3-bucket-kms-key"
  description       = "KMS key for Object Storage bucket encryption (Task 3)"
  default_algorithm = "AES_256"
  rotation_period   = "8760h"
}

resource "yandex_kms_symmetric_key_iam_binding" "bucket_key_encrypter_decrypter" {
  symmetric_key_id = yandex_kms_symmetric_key.bucket_key.id
  role             = "kms.keys.encrypterDecrypter"
  members = [
    "serviceAccount:${yandex_iam_service_account.lb_sa.id}",
  ]
}

resource "yandex_storage_bucket" "images" {
  access_key = yandex_iam_service_account_static_access_key.lb_sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.lb_sa_key.secret_key
  bucket     = var.bucket_name

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  anonymous_access_flags {
    read = true
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.lb_sa_storage_admin,
    yandex_kms_symmetric_key_iam_binding.bucket_key_encrypter_decrypter,
  ]
}

resource "yandex_storage_object" "image" {
  access_key = yandex_iam_service_account_static_access_key.lb_sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.lb_sa_key.secret_key
  bucket     = yandex_storage_bucket.images.bucket
  key        = var.bucket_object_key
  source     = "${path.module}/${var.bucket_image_source}"
  acl        = "public-read"

  depends_on = [yandex_storage_bucket.images]
}

resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-ig-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  bucket_image_url = "https://${yandex_storage_bucket.images.bucket}.storage.yandexcloud.net/${yandex_storage_object.image.key}"

  lamp_user_data = <<-EOT
    #!/bin/bash
    set -e

    yum install httpd -y
    systemctl enable httpd
    systemctl start httpd

    cat > /var/www/html/index.html <<HTML
    <html>
      <head><title>Task 2 LAMP</title></head>
      <body>
        <h1>My cool web-server</h1>
        <p>Image from Object Storage:</p>
        <img src="${local.bucket_image_url}" alt="Bucket image" width="600" />
      </body>
    </html>
    HTML
  EOT
}

resource "yandex_compute_instance_group" "lamp_group" {
  name               = "lamp-instance-group"
  folder_id          = var.yc_folder_id
  service_account_id = yandex_iam_service_account.lb_sa.id

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    boot_disk {
      initialize_params {
        image_id = var.lamp_image_id
        size     = 10
        type     = "network-hdd"
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.network.id
      subnet_ids         = [yandex_vpc_subnet.public.id]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.web_sg.id]
    }

    metadata = {
      ssh-keys  = "wrcs:${file(var.ssh_public_key)}"
      user-data = local.lamp_user_data
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.yc_zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  health_check {
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2

    tcp_options {
      port = 80
    }
  }

  load_balancer {
    target_group_name        = "lamp-group-targets"
    target_group_description = "Target group for task2 lamp instance group"
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.lb_sa_editor]
}

resource "yandex_lb_network_load_balancer" "lamp_nlb" {
  name = "lamp-network-load-balancer"

  listener {
    name = "lamp-http-listener"
    port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp_group.load_balancer.0.target_group_id

    healthcheck {
      name                = "lamp-http-healthcheck"
      interval            = 10
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2

      tcp_options {
        port = 80
      }
    }
  }
}
