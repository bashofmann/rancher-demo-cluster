data "digitalocean_domain" "zone" {
  name = "plgrnd.be"
}

resource "digitalocean_record" "kubecon" {
  domain = data.digitalocean_domain.zone.name
  type   = "A"
  name   = "*.kubecon"
  value  = sort(local.worker_ips)[0]
  ttl    = 60
}
output "dns" {
  value = digitalocean_record.kubecon.fqdn
}