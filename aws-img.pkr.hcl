# packer {
#   required_plugins {
#     amazon = {
#       source  = "github.com/hashicorp/amazon"
#       version = "= v1.2.9"
#     }
#   }
# }


# source "amazon-ebs" "ubuntu" {
#   ami_name      = "ami-yeedu-test"
#   instance_type = "t2.micro"
#   region        = "us-east-2"
#   source_ami    = "ami-00eb69d236edcfaf8"
#   ssh_username  = "ubuntu"
#   subnet_id     = "subnet-08b8ea566cb4def43"

#   tags = {
#     "resource" = "yeedu"
#     "env"      = "packer"
#   }
# }

# build {
#   sources = [
#     "source.amazon-ebs.ubuntu"
#   ]

#    provisioner "file"{
#     source = "scripts/setup.sh"
#     destination = "/tmp/setup.sh"
#   }
#   provisioner "file"{
#     source = "/home/mt24033/Work/creds/modak-nabu-4d560bbc2566-gcp.json"
#     destination = "/tmp/gcp-creds.json"
#   }
#   provisioner "shell"{
#     inline = [
#       "sudo chmod +x /tmp/setup.sh",
#       "sudo bash /tmp/setup.sh",
#       "sudo rm -rf /tmp/setup.sh",
#       "sudo rm -rf /tmp/gcp-creds.json"
#     ]
#   }

# }


packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "= v1.2.9"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ami-yeedu-test"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami    = "ami-00eb69d236edcfaf8"
  ssh_username  = "ubuntu"
  subnet_id     = "subnet-08b8ea566cb4def43"

  tags = {
    "resource" = "yeedu"
    "env"      = "packer"
  }

  launch_block_device_mappings {
    device_name = "/dev/xvda"
    volume_size = 25
    volume_type = "gp2"
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/tmp/setup.sh"
  }
  provisioner "file" {
    source      = "/home/mt24033/Work/creds/modak-nabu-4d560bbc2566-gcp.json"
    destination = "/tmp/gcp-creds.json"
  }
  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "sudo bash /tmp/setup.sh",
      "sudo rm -rf /tmp/setup.sh",
      "sudo rm -rf /tmp/gcp-creds.json"
    ]
  }
}
