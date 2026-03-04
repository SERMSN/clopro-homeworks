terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.95.0"
    }
  }
}

provider "yandex" {
  token     = var.yc_token             # Получить в IAM Yandex Cloud
  cloud_id  = var.yc_cloud_id          # Идентификатор облака
  folder_id = var.yc_folder_id         # Идентификатор каталога
  zone      = var.yc_zone              # Зона доступности
}