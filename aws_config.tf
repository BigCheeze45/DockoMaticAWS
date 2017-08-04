provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# AWS instance
resource "aws_instance" "machine" {
  count                       = "${var.instance_count}"
  ami                         = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${aws_subnet.subnet.id}"
  associate_public_ip_address = "true"
  security_groups             = ["${aws_security_group.security-group.id}"]
  key_name                    = "${aws_key_pair.key_pair.key_name}"

  root_block_device {
    volume_type           = "standard"
    volume_size           = 80
    iops                  = 0
    delete_on_termination = "true"
  }

  tags {
    Name = "${format("DockoMaticNode%0d", count.index + 1)}"
  }

  connection {
    user        = "${var.username}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "artifacts/install.zip"
    destination = "/tmp/install.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y unzip",
      "unzip -q /tmp/install.zip -d /tmp",
      "unzip -q /tmp/install/dockomatic.zip -d /tmp/install",
      "chmod +x /tmp/install/install_aws.sh",
      "cd /tmp/install; sudo ./install_aws.sh ${var.modeller_license_key}",
    ]
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name = "dockomatic_vpc"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "dockomatic_gateway"
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "dockomatic_main_rt"
  }
}

resource "aws_main_route_table_association" "main_rt_assoc" {
  vpc_id         = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.main_rt.id}"
}

resource "aws_subnet" "subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"

  tags {
    Name = "dockomatic_subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }

  tags {
    Name = "dockomatic_public_rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "dockomatic_key_pair"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "security-group" {
  name   = "dockomatic_security_group"
  vpc_id = "${aws_vpc.vpc.id}"

  # HTTPS (secure internet access)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (internet access)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Do not delete
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Print host names with their public IP to connect to
output "segment_info" {
  value = "HOSTS: ${join(", ", aws_instance.machine.*.tags.Name)}\n\t\t PUB_IP: ${join(", ", aws_instance.machine.*.public_ip)}"
}
