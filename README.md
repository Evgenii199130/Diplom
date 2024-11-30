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
ssh_key_default = file("./authorized_key.json")
}

  resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

  resource "yandex_vpc_subnet" "subnet-1" {
  name = "subnet1"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

  resource "yandex_vpc_subnet" "subnet-bastion" {
  name = "subnet-bastion"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

  resource "yandex_compute_disk" "boot-disk-1" {
  name = "boot-disk-1"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = "10"
  image_id = "fd87j6d92jlrbjqbl32q"
}

  resource "yandex_compute_disk" "boot-disk-2" {
  name = "boot-disk-2"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = "10"
  image_id = "fd87j6d92jlrbjqbl32q"
}

  resource "yandex_compute_instance" "vm-1" {
  name = "vm1_web-server"
  zone = "ru-central1-a"
  resources {
  cores = 2
  memory = 2
}

  boot_disk {
  disk_id = yandex_compute_disk.boot-disk-1.id
}

  network_interface {
  subnet_id = yandex_vpc_subnet.subnet-1.id
}

  metadata = {
  ssh-keys = "ubuntu:${local.ssh_key_default}"
}
}

  resource "yandex_compute_instance" "vm-2" {
  name = "vm2_web-server"
  zone = "ru-central1-a"
 resources {
 cores = 2
 memory = 2
}

boot_disk {
disk_id = yandex_compute_disk.boot-disk-2.id
}

network_interface {
subnet_id = yandex_vpc_subnet.subnet-1.id
}

metadata = {
ssh-keys = "ubuntu:${local.ssh_key_default}"
}
}

resource "yandex_compute_instance" "bastion" {
name = "vm4_bastion-host"
zone = "ru-central1-a"
resources {
cores = 2
memory = 2
}

boot_disk {
initialize_params {
image_id = "fd87j6d92jlrbjqbl32q"
}
}

network_interface {
subnet_id = yandex_vpc_subnet.subnet-bastion.id
nat = true
}

metadata = {
ssh-keys = "ubuntu:${local.ssh_key_default}"
}
}

resource "yandex_lb_network_load_balancer" "web_lb" {
name = "web-load-balancer"
region = "ru-central1"

listener {
name = "http-listener"
port = 80
protocol = "tcp"
}

backend {
group {
instance_group_id = yandex_compute_instance.vm-1.id
}
group {
instance_group_id = yandex_compute_instance.vm-2.id
}
}
}

resource "yandex_compute_snapshot_schedule" "snapshot_schedule" {
name = "snapshot-schedule"
disk_id = yandex_compute_disk.boot-disk-1.id

snapshot_schedule {
cron = "0 0 * * *"
}
}

output "internal_ip_address_vm_1" {
value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "bastion_ip_address" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}

output "external_ip_address_via_bastion" {
  value = "${yandex_compute_instance.bastion.network_interface.0.ip_address}"   
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

Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix.
Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.
Устанавливаем zabbix-server на локальную машину используя инструкцию на сайте.
устанавливаем zabbix-agent на ВМ.
В zabbix-agent.conf файле ВМ указываем ip адрес zabbix-servera.

Ответ:

Устанавливаем zabbix-server на вм3 используя инструкцию на сайте.
Устанавливаем zabbix-agent на ВМ.
В zabbix-agent.conf файле ВМ указываем ip адрес zabbix-servera.

(IP могут отличатся, по причине того, что делал в разное время отключал вм.)

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-33-55.png)

В веб интерфейсе создаем новые узлы сети

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-35-53.png)
![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-36-13.png)
![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-37-06.png)

Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.
Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

Ответ:

Запускаем Elasticsearch в докер контейнере.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-29%2019-51-51.png)

Запускаем Kibana также в докер контейнере.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-31%2022-47-11.png)

Заходим на веб интерфейс.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-20-52.png)
![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-10-27%2017-20-5111.png)

Создаем контейнер с Elasticsearch\Filebeat.

```
version: "3.9"
services:
  nginx:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/html:/usr/share/nginx/html
      - ./nginx/logs:/var/log/nginx

  elasticsearch:
    image: elasticsearch:7.17.6
    ports:
      - "9200:9200"
      - "9300:9300"
    environment:
      - discovery.type=single-node
      - node.store.allow_mmap=false
    ulimits:
      memlock:
        soft: -1
        hard: -1

  filebeat:
    image: elastic/filebeat:8.6.2 #  Используем последнюю версию, которая вам подошла
    volumes:
      - ./filebeat/filebeat.yml:/usr/local/filebeat/filebeat.yml
      - ./nginx/logs:/var/log/nginx
    depends_on:
      - elasticsearch
    networks:
      - elk_default

networks:
  elk_default:
```
```
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/access.log
    - /var/log/nginx/error.log
  tags: ["nginx"]

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "nginx-*"
```

Запускаем контейнер.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-11-21%2020-27-40.png)

Заходим в веб интерфейс кибана.

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202024-11-21%2020-28-11.png)

Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.
Настройте Security Groups соответствующих сервисов на входящий трафик только к нужным портам.
Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Эта вм будет реализовывать концепцию bastion host . Синоним "bastion host" - "Jump host". Подключение ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью ProxyCommand . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)
Исходящий доступ в интернет для ВМ внутреннего контура через NAT-шлюз.

Создаем вм4

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/1%20%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%B5%D0%BC%20%D0%B2%D0%BC4%20%D0%BE%D0%BD%20%D0%B6%D0%B5%20%D0%B1%D0%B0%D1%81%D1%82%D0%B8%D0%BE%D0%BD%20%D1%85%D0%BE%D1%81%D1%82.png)

Установка и настройка ssh сервера

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/2%20%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0%20%D0%B8%20%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0%20ssh%20%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B0.png)

Настройка файла config

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/3%20%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0%20%D1%84%D0%B0%D0%B9%D0%BB%D0%B0%20config.png)

добавляем в файл строку для перенаправления в сеть.png

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/4%20%D0%B4%D0%BE%D0%B1%D0%B0%D0%B2%D0%BB%D1%8F%D0%B5%D0%BC%20%D0%B2%20%D1%84%D0%B0%D0%B9%D0%BB%20%D1%81%D1%82%D1%80%D0%BE%D0%BA%D1%83%20%D0%B4%D0%BB%D1%8F%20%D0%BF%D0%B5%D1%80%D0%B5%D0%BD%D0%B0%D0%BF%D1%80%D0%B0%D0%B2%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F%20%D0%B2%20%D1%81%D0%B5%D1%82%D1%8C.png)

настройка NAT.png

![1](https://github.com/Evgenii199130/Diplom/blob/main/scrin/5%20%D0%BD%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B0%20NAT.png)



Устанавливаем ансимбл

```
   sudo apt update
   sudo apt install -y ansible
```

Создаем файл ansible.cfg
```
     [defaults]
     transport = ssh

     [ssh_connection]
     ssh_args = -o ProxyCommand="ssh -W %h:%p bastion"
```

Создаем файл инвентаря например hosts.ini
```
     [webservers]
     vm1
     vm2

     [logservers]
     vm3
```


Настройка IP Forwarding:
   На Bastion Host вам нужно включить пересылку IP-пакетов. Для этого откройте файл /etc/sysctl.conf и добавьте или раскомментируйте следующую строку:
```
 net.ipv4.ip_forward=1
```
Затем примените изменения:

```
   sudo sysctl -p
```
Настройка NAT:

На Bastion Host, чтобы разрешить NAT. Интерфейс, который подключен к интернету, и внутренний интерфейс (например, eth1), который подключен к вашим внутренним серверам, выполните следующие команды:
```
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
   sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
   sudo iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```
Сохранение настроек iptables:
```
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```
Настройка шлюза:
   На каждом из внутренних серверов (vm1, vm2, vm3) вам нужно указать Bastion Host как шлюз. Для этого отредактируем файл /etc/network/interfaces или используйте команду ip route для добавления маршрута.
```
sudo ip route add default via 89.169.156.209
```
Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

Создаем папку для резервных копий mkdir -p /path/to/backups.
Создайте файл скрипта, например backup.sh:
```
#!/bin/bash

   # Дата для имени файла
   DATE=$(date +"%Y-%m-%d")

   # Путь к диску.
   DISK="/dev/vda"

   # Папка для сохранения резервных копий
   BACKUP_DIR="/path/to/backups"

   # Создание снимка
   dd if=$DISK of=$BACKUP_DIR/backup-$DATE.img bs=4M status=progress

   # Удаление старых файлов резервных копий старше 7 дней
   find $BACKUP_DIR -type f -name "*.img" -mtime +7 -exec rm {} \;
```
Делаем скрипт исролняемым.
```
chmod +x /path/to/backup.sh
```
Настройка cron для автоматического выполнения скрипта:

Открываем crontab:
crontab -e

Добавляем задачу:
   Вставляем строку, чтобы запускать резервное копирование каждый день в 2:00:

```
   0 2 * * * /path/to/backup.sh
```
Это означает, что скрипт будет выполняться каждый день в 2:00 ночи.
