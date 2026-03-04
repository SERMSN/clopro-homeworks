# Отчёт по ДЗ «Организация сети»

## Манифесты Terraform

- [main.tf](infrastructure/terraform/main.tf)
- [variables.tf](infrastructure/terraform/variables.tf)
- [outputs.tf](infrastructure/terraform/outputs.tf)
- [providers.tf](infrastructure/terraform/providers.tf)

## Результат Terraform

1. `terraform apply` — старт выполнения.

![terraform apply start](images/terraform%20apply_1_start.png)

2. `terraform apply` — завершение, ресурсы созданы.

![terraform apply finish](images/terraform%20apply_2_finish_create.png)

3. Список ВМ в Yandex Cloud: `public-vm`, `private-vm`, `nat-instance`.

![YC VM list](images/terraform%20apply_3_scrin_YC_VM.png)

## Проверка публичной ВМ

1. Подключение по SSH к `public-vm`.

![public vm check 1](images/Проверка%20публичной%20ВМ_1.png)

2. Проверка доступа в интернет с `public-vm` (часть 1).

![public vm check 2](images/Проверка%20публичной%20ВМ_2.png)

3. Проверка доступа в интернет с `public-vm` (часть 2).

![public vm check 3](images/Проверка%20публичной%20ВМ_3.png)

## Проверка приватной ВМ

1. Подключение по SSH к `private-vm` через `public-vm`.

![private vm check 1](images/Проверка%20приватной%20ВМ_1.png)

2. Проверка доступа в интернет с `private-vm` через NAT (часть 1).

![private vm check 2](images/Проверка%20приватной%20ВМ_2.png)

3. Проверка доступа в интернет с `private-vm` через NAT (часть 2).

![private vm check 3](images/Проверка%20приватной%20ВМ_3.png)
