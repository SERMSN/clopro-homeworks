# Отчёт по домашним заданиям

## ДЗ 1. Организация сети

### Манифесты Terraform

- [main.tf](infrastructure/terraform/main.tf)
- [variables.tf](infrastructure/terraform/variables.tf)
- [outputs.tf](infrastructure/terraform/outputs.tf)
- [providers.tf](infrastructure/terraform/providers.tf)

### Результат Terraform

1. `terraform apply` — старт выполнения.

![terraform apply start](images/terraform%20apply_1_start.png)

2. `terraform apply` — завершение, ресурсы созданы.

![terraform apply finish](images/terraform%20apply_2_finish_create.png)

3. Список ВМ в Yandex Cloud: `public-vm`, `private-vm`, `nat-instance`.

![YC VM list](images/terraform%20apply_3_scrin_YC_VM.png)

### Проверка публичной ВМ

1. Подключение по SSH к `public-vm`.

![public vm check 1](images/Проверка%20публичной%20ВМ_1.png)

2. Проверка доступа в интернет с `public-vm` (часть 1).

![public vm check 2](images/Проверка%20публичной%20ВМ_2.png)

3. Проверка доступа в интернет с `public-vm` (часть 2).

![public vm check 3](images/Проверка%20публичной%20ВМ_3.png)

### Проверка приватной ВМ

1. Подключение по SSH к `private-vm` через `public-vm`.

![private vm check 1](images/Проверка%20приватной%20ВМ_1.png)

2. Проверка доступа в интернет с `private-vm` через NAT (часть 1).

![private vm check 2](images/Проверка%20приватной%20ВМ_2.png)

3. Проверка доступа в интернет с `private-vm` через NAT (часть 2).

![private vm check 3](images/Проверка%20приватной%20ВМ_3.png)

## ДЗ 2. Вычислительные мощности. Балансировщики нагрузки

### Манифесты Terraform

- [main.tf](infrastructure/terraform/main.tf)
- [variables.tf](infrastructure/terraform/variables.tf)
- [outputs.tf](infrastructure/terraform/outputs.tf)
- [providers.tf](infrastructure/terraform/providers.tf)

### Результат Terraform

1. `terraform apply` — старт выполнения.

![task2 terraform apply start](images/Task2-terraform%20apply%20start.png)

2. `terraform apply` — завершение, ресурсы созданы.

![task2 terraform apply finish](images/Task2-terraform%20apply%20finish.png)

3. Созданные ресурсы в Yandex Cloud.

![task2 resources yc](images/Task2-ресурсы%20в%20YC.png)

4. Стартовый список ВМ в Yandex Cloud.

![task2 starting vm yc](images/Task2-starting-VM-YC.png)

### Проверка бакета и картинки

1. Проверка бакета в Object Storage.

![task2 bucket check 1](images/Task2-Проверка%20бакета%20и%20картинки1.png)

2. Проверка публичной ссылки на объект (картинку).

![task2 bucket check 2](images/Task2-Проверка%20бакета%20и%20картинки2.png)

### Проверка Instance Group

1. Общая информация по группе.

![task2 instance group 1](images/Task2-Проверка%20Instance%20Group-1.png)

2. Состав инстансов группы.

![task2 instance group 2](images/Task2-Проверка%20Instance%20Group-2.png)

3. Статус инстансов/проверок.

![task2 instance group 3](images/Task2-Проверка%20Instance%20Group-3.png)

### Проверка Network Load Balancer

1. Проверка настроенного балансировщика.

![task2 nlb check](images/Task2-Проверка%20Network%20Load%20Balancer-1.png)

### Проверка веб-страницы через балансировщик

1. Открытие веб-страницы по публичному IP балансировщика.

![task2 web via lb](images/Task2-Проверка%20веб-страницы%20через%20балансировщик.png)

### Проверка отказоустойчивости

1. Проверка поведения после удаления инстанса (шаг 1).

![task2 fault tolerance 1](images/Task2-Проверка%20отказоустойчивости-1.png)

2. Проверка поведения после удаления инстанса (шаг 2).

![task2 fault tolerance 2](images/Task2-Проверка%20отказоустойчивости-2.png)

3. Проверка поведения после удаления инстанса (шаг 3).

![task2 fault tolerance 3](images/Task2-Проверка%20отказоустойчивости-3.png)

4. Проверка поведения после удаления инстанса (шаг 4).

![task2 fault tolerance 4](images/Task2-Проверка%20отказоустойчивости-4.png)

5. Проверка поведения после удаления инстанса (шаг 5).

![task2 fault tolerance 5](images/Task2-Проверка%20отказоустойчивости-5.png)

6. Проверка поведения после удаления инстанса (шаг 6).

![task2 fault tolerance 6](images/Task2-Проверка%20отказоустойчивости-6.png)

7. Проверка поведения после удаления инстанса (шаг 7).

![task2 fault tolerance 7](images/Task2-Проверка%20отказоустойчивости-7.png)

## ДЗ 3. Безопасность в облачных провайдерах

### Манифесты Terraform

- [main.tf](infrastructure/terraform/main.tf)
- [variables.tf](infrastructure/terraform/variables.tf)
- [outputs.tf](infrastructure/terraform/outputs.tf)
- [providers.tf](infrastructure/terraform/providers.tf)

### Пункт 1. Шифрование бакета с помощью KMS (Terraform)

1. Выполнено применение Terraform с ресурсами KMS и обновлением бакета.

![task3 terraform apply](images/Task3-Подтверждение%20применения%20Terraform.png)

2. Создан ключ KMS `task3-bucket-kms-key` для шифрования бакета.

![task3 kms key](images/Task3-Созданный%20KMS-ключ.png)

3. Настроены права service account на использование ключа (`kms.keys.encrypterDecrypter`).

![task3 kms sa role](images/Task3-Права%20на%20ключ%20для%20service%20account.png)

4. Для бакета включено серверное шифрование через KMS-ключ.

![task3 bucket encryption](images/Task3-Шифрование%20включено%20на%20бакете.png)

### Пункт 2. Ручная часть в Yandex Cloud: статический сайт + HTTPS

Примечание: верификация сертификата может занимать длительное время из-за обновления DNS-записей. В отчете зафиксированы выполненные шаги и состояние процесса до финального `Issued`.

1. Создан отдельный бакет для статического сайта.

![task3 website bucket created](images/Task3-Бакет.png)

2. Загружены файлы сайта в Object Storage.

![task3 website objects](images/Task3-бакет%20объекты.png)

3. Включен режим Website hosting.

![task3 website settings](images/Task3-бакет-нвстройки-вебсайт.png)

4. Запущен выпуск сертификата в Certificate Manager.

![task3 cert issuance](images/Task3-%20Выпуск%20сертификата.png)

5. В DNS у регистратора добавлены записи для сайта и проверки сертификата (`_acme-challenge`).
6. После статуса `Issued` сертификат будет привязан к бакету в разделе `HTTPS`.
7. После привязки сертификата будет выполнена проверка сайта по `https://` (замок в браузере).
