packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "terraform-ubuntu-prj-19" {
  ami_name      = "terraform-ubuntu-prj-19-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"

  tag {
    key   = "Name"
    value = "terraform-ubuntu-prj-19"
  }
}

build {
  sources = ["source.amazon-ebs.terraform-ubuntu-prj-19"]

  provisioner "shell" {
    script = "ubuntu.sh"
  }
}
