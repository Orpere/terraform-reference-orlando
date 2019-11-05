resource "aws_instance" "web" {
  count = "${var.instance_count}"

  # count initiate the default variable count as value 2 
}

resource "null_resource" "web" {
  ami          = "${var.ami_id}"
  instance_type = "${instance_type}"
  connection {
    host = "${null_resource_count.web.public_ip}"
  }
  
  tags = {
    Name = "web null resource"
  }
}

