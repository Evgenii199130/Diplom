resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_disk" "disk-bastion_host" {
  name     = "disk-bastion_host"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_disk" "disk-zabbix" {
  name     = "disk-zabbix"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_disk" "disk-elastic" {
  name     = "disk-elastic"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_disk" "disk-kibana" {
  name     = "disk-n-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}
