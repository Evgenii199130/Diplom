# Diplom

Инфраструктура

Для развёртки инфраструктуры используйте Terraform и Ansible.

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal - для этого достаточно при создании ВМ указать name=example, hostname=examle !!

Важно: используйте по-возможности минимальные конфигурации ВМ:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая.

Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

Ответ:

Создаем директорию, в ней создаем файл с расширением .tf
Для указания провайдера.

default.tf

```

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
  }
}
provider "yandex" {
  cloud_id = "b1g7df4is4ig1nnihpib"
  folder_id = "b1g47pa7960h8722b17k"
  service_account_key_file = "/home/evgenii/yandex_diplom/authorized_key.json"
}

```
```
Создаем файл конфигурации compute.tf.

'''

locals {
  ssh_key_default = file("/home/evgenii/yandex_diplom/authorized_key.json")
}


resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd87j6d92jlrbjqbl32q"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "10"
  image_id = "fd87j6d92jlrbjqbl32q"
}
resource "yandex_compute_instance" "vm-1" {
  name = "vm1"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
 }
}

resource "yandex_compute_instance" "vm-2" {
  name = "vm2"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
 metadata = {
    ssh-keys = "ubuntu:${var.ssh_key}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}


output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}
```

Запускаем команду terraform init

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-20-52.png)

Запускаем команду terraform plan.
После когда видим, что terraform plan не выдал ошибок запускаем terraform apply.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-26-37.png)

У меня просто все уже созданно.

Таким образом создается 2вм.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-29-02.png)

Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.
Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.
Виртуальные машины не должны обладать внешним Ip-адресом, те находится во внутренней сети. Доступ к ВМ по ssh через бастион-сервер. Доступ к web-порту ВМ через балансировщик yandex cloud.
Настройка балансировщика:
Создайте Target Group, включите в неё две созданных ВМ.


Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.


Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.


Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.


Протестируйте сайт curl -v <публичный IP балансера>:80

Ответ:

Вводим команду на вм sudo apt update && sudo apt upgrade -y
Устанавливаем nginx

Копируем статический файл на вм командой scp /home/evgenii/dsfjug.jpg ubuntu@"ip vm"/var/www/html.

Заходим на сайт, видим статический файл который копировали на вм.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-28%2021-21-59.png)

curl -v 84.252.129.232:80

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-28%2021-27-27.png)




