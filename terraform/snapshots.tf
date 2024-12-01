resource "yandex_compute_snapshot_schedule" "default1" {
  name        = "default1"
  description = "Ежедневные снимки, хранятся 7 дней"

  schedule_policy {
    expression = "0 0 ? * *"
  }

  retention_period = "168h"

  snapshot_spec {
    description = "retention-snapshot"

  }

  disk_ids = [
    "${yandex_compute_disk.disk-vm1_web-server.id}",
    "${yandex_compute_disk.disk-vm2_web-server.id}",
    "${yandex_compute_disk.disk-vm4_bastion-host.id}",
    "${yandex_compute_disk.disk-vm3-zabbix.id}",
    "${yandex_compute_disk.disk-vm5-elastic.id}",
    "${yandex_compute_disk.disk-vm6-kibana.id}",
  ]

  depends_on = [
    yandex_compute_instance.vm1_web-server,
    yandex_compute_instance.vm2_web-server,
    yandex_compute_instance.vm4_bastion-host,
    yandex_compute_instance.vm3-zabbix,
    yandex_compute_instance.vm5-elastic,
    yandex_compute_instance.vm6-kibana
  ]

}
