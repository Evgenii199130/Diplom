locals {
ssh_key_default = file("./authorized_key.json")
}

#----WWW---
resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_instance" "vm1" {
  name                      = "vm1_web-server"
  zone                      = "ru-central1-a"
}
  resources {
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.inner-vm1_web-server.id
    security_group_ids = [yandex_vpc_security_group.inner.id]
    ip_address         = "10.0.1.3"
  }

  metadata = {
  ssh-keys = "ubuntu:${local.ssh_key_default}"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

 resource "yandex_compute_instance" "vm-2" {
  name = "vm2_web-server"
  zone = "ru-central1-b"
 resources {
 cores = 2
 memory = 2
}

 boot_disk {
  disk_id = yandex_compute_disk.boot-disk-2.id
}

 network_interface {
    subnet_id          = yandex_vpc_subnet.inner-vm2_web-server.id
    security_group_ids = [yandex_vpc_security_group.inner.id]
    ip_address         = "10.0.2.3"
  }


metadata = {
ssh-keys = "ubuntu:${local.ssh_key_default}"
}
}

#---bastion---
resource "yandex_compute_disk" "disk-bastion_host" {
  name     = "disk-bastion_host"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_instance" "bastion" {
name = "vm4_bastion-host"
zone = "ru-central1-b"
resources {
cores = 2
memory = 2
}

boot_disk {
    disk_id = yandex_compute_disk.disk-bastion_host.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.inner.id, yandex_vpc_security_group.public-bastion.id]
    ip_address         = "10.0.4.4"
  }


metadata = {
ssh-keys = "ubuntu:${local.ssh_key_default}"
}
}

#---zabbix---

resource "yandex_compute_disk" "disk-zabbix" {
  name     = "disk-zabbix"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_instance" "vm3-zabbix" {
  name                      = "vm3-zabbix"
  zone                      = "ru-central1-b" #c

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk-zabbix.id
  }


  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.inner.id, yandex_vpc_security_group.public-zabbix.id]
    ip_address         = "10.0.4.5"
  }

metadata = {
ssh-keys = "ubuntu:${local.ssh_key_default}"
}
}

#---elastic---
resource "yandex_compute_disk" "disk-elastic" {
  name     = "disk-elastic"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_instance" "vm5-elastic" {
  name                      = "vm5-elastic"
  zone                      = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk-elastic.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.inner-services.id
    security_group_ids = [yandex_vpc_security_group.inner.id]
    ip_address         = "10.0.3.4"
  }
#---kibana---
resource "yandex_compute_disk" "disk-kibana" {
  name     = "disk-n-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = 10
  image_id = "fd87j6d92jlrbjqbl32q"

}

resource "yandex_compute_instance" "vm6-kibana" {
  name                      = "vm6-kibana"
  hostname                  = "kibana"
  zone                      = "ru-central1-b"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk-kibana.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.inner.id, yandex_vpc_security_group.public-kibana.id]
    ip_address         = "10.0.4.3"
  }
metadata = {
ssh-keys = "ubuntu:${local.ssh_key_default}"
}
}
