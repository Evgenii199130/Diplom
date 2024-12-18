output "external_ip_addres_load_balancer" {
  value = yandex_alb_load_balancer.new_lb.listener.0.endpoint.0.address.0.external_ipv4_address
}
output "bastion-host" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}
output "vm6-kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
