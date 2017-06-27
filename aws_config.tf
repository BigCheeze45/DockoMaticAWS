provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "machine" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
