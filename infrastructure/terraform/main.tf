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
