output "public_ip" {
  value = "${module.module_web.web.public_ip}"
}

output "server_id" {
  value = "${module.random_pet.random_pet.server.id}"
}
