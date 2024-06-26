variable "cidr" {
    default = "10.0.0.0/24"
}

resource "aws_vpc" "man-vpc" {
    cidr_block = var.cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
      Name = "man-vpc"
    }
}

variable "existing_key_pair" {
    type = string
    default = "test-keypair"
}


resource "aws_subnet" "man-sub1" {
    vpc_id = aws_vpc.man-vpc.id
    cidr_block = "10.0.0.0/27"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "man-igw" {
    vpc_id = aws_vpc.man-vpc.id
}

resource "aws_route_table" "man-rtable1" {
    vpc_id = aws_vpc.man-vpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.man-igw.id
    }
}

resource "aws_route_table_association" "man-rta1" {
    subnet_id = aws_subnet.man-sub1.id
    route_table_id = aws_route_table.man-rtable1.id
}

resource "aws_security_group" "jenkins-sg" {
    name = "jenkins-sec"
    vpc_id = aws_vpc.man-vpc.id

    ingress{
        description = "http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        description = "http"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        description = "ssh"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{
        description = "all out going traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "jenkins-sec"
    }
}

variable "ami" {
    default = "ami-04b70fa74e45c3917"
  
}

resource "aws_instance" "jenkins-server" {
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = aws_subnet.man-sub1.id
  security_groups = [aws_security_group.jenkins-sg.id]
  key_name = var.existing_key_pair


  provisioner "remote-exec" {
    inline = [
        # install java 
        "sudo apt update",
        "sudo apt install openjdk-17-jre -y",
        #jenkins installation 
        #"curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
        "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
        "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null",
        "sudo apt-get update",
        "sudo apt-get install jenkins -y",
        "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file("C:\\Users\\Shruthi\\Downloads\\test-keypair.pem")
      host = self.public_ip
        }
    }
  
}

output "jenkins_ip" {
    value = aws_instance.jenkins-server.public_ip
}

