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
