provider "aws" {
    region = "us-eaast-1"
}

variable "existing_key_pair" {
    type = string
    default = "test-keypair"
}
resource "aws_instance" "web-server-man" {
    ami = "ami-08a0d1e16fc3f61ea"
    instance_type = "t2.micro"
    key_name = var.existing_key_pair

    tags = {
      name = "web-server-man"
    }
  
}