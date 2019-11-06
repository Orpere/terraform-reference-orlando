output "public_ip" {
  value = "${null_resource.web.*.public_ip}"
}