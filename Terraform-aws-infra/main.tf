provider "aws" {
    region = "us-eaast-1"
}

resource "aws_instance" "web-server-man" {
    ami = "ami-08a0d1e16fc3f61ea"
    instance_type = "t2.micro"
    tags = {
      name = "web-server-man"
    }
  
}