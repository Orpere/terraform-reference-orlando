# Terraform learning exercise

 note: the links on the document show where the quotation were taken from

## What terraform is?

[Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.](https://www.terraform.io/intro/index.html)

## Variables

Variables are defined parameters we can use to pass information to the terraform files.

Variables are used for:

  1) To store sensitive values
  2) Refactoring existing values
  3) keep sensitive data as keys and passwords out of code control systems as Github
  4) populate other variables in the terraform configuration

example :
on module.web>variables.tf

```terraform
variable "instance_count" {
  default     = "2"
  description = "count the number of instances"
}

variable "ami_id" {}

variable "instance_type" {}
```

a variable must be defined and the values can be defined on other file as terraform.tfvars

```terraform
instance_count = "2"
ami_id         = " " # it should be a valid ami
instance_type  = " " # should be a valid type
```

Note: default variables have low precedence. which can be override by CLI

## Outputs

Is a feature to display metadata we can also say is other type of variable. It can be used to extract informative metadata from terraform or for interpolation

example:
 outputs.tf --> are getting servers public ip from the module_web and the server id from the module_pet

 ```terraform
 output "public_ip" {
  value = "${module.module_web.web.public_ip}"
}

output "server_id" {
  value = "${module.random_pet.random_pet.server.id}"
}

 ```

## Modules

Modules are self contain packages in terraform and are used to reuse code.
Modules must be defined on the root main.tf as terraform can't see any of the configurations inside the module with out the right path.
The way how terraform can see meta information from the module is using the module outputs.

example:

main.tf module definition

```terraform
module "module_web" {
  source = "./module_web"
  
}
module "random_pet" {
  source = "./random_pet"
}
```

Folder structure

```bash
.
├── README.md
├── main.tf
├── module_web
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── outputs.tf
└── random_pet
    ├── main.tf
    ├── outputs.tf
    └── variables.tf
```

## Providers

Providers are plugins which give to terraform the capacity of interact with the infrastructure APIs, is the way of create,destroy,update or just take meta information from the servers or cloud providers.
For a complete list of providers you can check the [link](https://www.terraform.io/docs/providers/index.html)

## Random Providers

Random Providers permit us to use the terraform logical with out interfere directly with the infrastructure as example it can attribute random values to variables.

we know the follow resources:

1) [random_id](https://www.terraform.io/docs/providers/random/r/id.html)
2) [random_integer](https://www.terraform.io/docs/providers/random/r/integer.html)
3) [random_password](https://www.terraform.io/docs/providers/random/r/password.html)
4) [random_pet](https://www.terraform.io/docs/providers/random/r/pet.html)
5) [random_shuffle](https://www.terraform.io/docs/providers/random/r/shuffle.html)
6) [random_string](https://www.terraform.io/docs/providers/random/r/string.html)
7) [random_uuid](https://www.terraform.io/docs/providers/random/r/uuid.html)

Note: [for more information](https://www.terraform.io/docs/providers/index.html)

example: the random_pet module which will tag the server on this case with a pet name like "web-server-dog"

```terraform
resource "random_pet" "server" {
  keepers = {
    # Generate a new pet name each time we switch to a new AMI id
    ami_id = "${var.ami_id}"
  }
   byte_length = 8
}

resource "aws_instance" "server" {
  tags = {
    Name = "web-server-${random_pet.server.id}"
  }

  # Read the AMI id "through" the random_pet resource to ensure that
  # both will change together.
  ami = "${random_pet.server.keepers.ami_id}"
  # ... (other aws_instance arguments) ...

}
```

these terraform files are using a null Provider

Null Provider
[The null provider is a rather-unusual provider that has constructs that intentionally do nothing. This may sound strange, and indeed these constructs do not need to be used in most cases, but they can be useful in various situations to help orchestrate tricky behavior or work around limitations.](https://www.terraform.io/docs/providers/null/index.html)

 example:

 ```terraform
resource "aws_instance" "web" {  # i call it aws_instance to my better understanding but don't need to be aws it can be anything.
  count = "${var.instance_count}"
  # count initiate the default variable count as value 2 as defined on variables.tf
}

resource "null_resource" "web" { # define a null_resource
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  connection {
    host = "${aws_instance.web.public_ip}"
  }

 ```

## Provisioner

[Provisioners can be used to model specific actions on the local machine or on a remote machine in order to prepare servers or other infrastructure objects for service.](https://www.terraform.io/docs/provisioners/index.html)

NOTE: on my opinion is the way terraform uses to interact with external software or create connections to the infrastructure. as example Terraform has Built-in Provisioners:

  1) [chef Provisioner](https://www.terraform.io/docs/provisioners/chef.html)
  2) [file Provisioner](https://www.terraform.io/docs/provisioners/file.html)
  3) [habitat Provisioner](https://www.terraform.io/docs/provisioners/habitat.html)
  4) [local-exec Provisioner](https://www.terraform.io/docs/provisioners/local-exec.html)
  5) [puppet Provisioner](https://www.terraform.io/docs/provisioners/puppet.html)
  6) [remote-exec Provisioner](https://www.terraform.io/docs/provisioners/remote-exec.html)
  7) [salt-masterless Provisioner](https://www.terraform.io/docs/provisioners/salt-masterless.html)

example: module_web

```terraform
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
```
