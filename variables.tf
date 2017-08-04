variable "access_key" {
  description = "AWS IAM user access key. See https://goo.gl/b9rHov"
}

variable "secret_key" {
  description = "AWS IAM user secret key. See https://goo.gl/b9rHov"
}

variable "aws_key_pair" {}

variable "modeller_license_key" {
  description = "Modeller license key"
}

variable "region" {
  default = "us-east-1"
}

variable "username" {
  default = "fedora"
}

variable "amis" {
  type = "map"

  default = {
    # Oregon
    us-west-2 = "ami-2c1c0f55"

    # N. Virginia
    us-east-1 = "ami-bb6065ad"

    # N. California
    us-west-1 = "ami-31113e51"

    # Tokyo
    ap-northeast-1 = "ami-6e7b6409"

    # Sigapore
    ap-southeast-1 = "ami-29850f4a"

    # Sydney
    ap-southeast-2 = "ami-ebc2d088"

    # Frankfurt
    eu-central-1 = "ami-5364c43c"

    # Ireland
    eu-west-1 = "ami-aac928d3"

    # Sao Paulo
    sa-east-1 = "ami-6675000a"
  }
}

# See link for detail: https://goo.gl/tLFwSp
variable "instance_type" {
  default = "t2.micro"
}

variable "instance_count" {
  description = "The total number of EC2 (VMs) to create and power on. Default is 1"
  default     = 1
}
