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

```
variable "instance_count" {
  default     = "2"
  description = "count the number of instances"
}

variable "ami_id" {}

variable "instance_type" {}
```

a variable must be defined and the values can be defined on other file as terraform.tfvars
```
instance_count = "2"
ami_id         = " " # it should be a valid ami
instance_type  = " " # should be a valid type
```
Note: default variables have low precedence. which can be override by CLI

## Outputs
Is a feature to display metadata we can also say is other type of variable. It can be used to extract informative metadata from terraform or for interpolation

example:
 outputs.tf --> are getting servers public ip from the module_web and the server id from the module_pet

 ```
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
```

module "module_web" {
  source = "./module_web"
  
}
module "random_pet" {
  source = "./random_pet"
}
```
Folder structure 
```
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




these terraform files are using a null Provider

Null Provider
[The null provider is a rather-unusual provider that has constructs that intentionally do nothing. This may sound strange, and indeed these constructs do not need to be used in most cases, but they can be useful in various situations to help orchestrate tricky behavior or work around limitations.](https://www.terraform.io/docs/providers/null/index.html)

 example:

 ```terraform
resource "aws_instance" "web" {  # i call it aws_instance to my better understanding but don't need to be aws it can be anything.
  count = "${var.instance_count}"
  # count initiate the default variable count as value 2 
}

resource "null_resource" "web" { # define a null_resource
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  connection {
    host = "${aws_instance.web.public_ip}"
  }

 ```
