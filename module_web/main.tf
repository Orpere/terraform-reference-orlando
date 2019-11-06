resource "aws_instance" "web" {
  count = "${var.instance_count}"
  # count initiate the default variable count as value 2 
}

resource "null_resource" "web" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  connection {
    host = "${aws_instance.web.public_ip}"
  }

  tags = {
    Name = "web ${var.instance_count.index+1}/${var.instance_count}"
  }
   provisioner "local-exec" {
    command = "echo ${aws_instance.web.public_ip} >> my_infrastructure.txt" # this will add the ip to the terrafom local machine
  }
}

