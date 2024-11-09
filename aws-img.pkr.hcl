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
# Packer configuration file


packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "= v1.2.9"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

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

  run_tags = {
    "resource" = "yeedu"
    "env"      = "packer"
  }

  launch_block_device_mappings {
    device_name           = "/dev/sda1" 
    volume_size           = 25     
    volume_type           = "gp2"       
    delete_on_termination = true
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  # Provision the AWS credentials file in JSON format
  provisioner "file" {
    content = <<-EOF
    {
      "AWS_ACCESS_KEY_ID": "${var.aws_access_key_id}",
      "AWS_SECRET_ACCESS_KEY": "${var.aws_secret_access_key}"
      "AWS_DEFAULT_REGION": "${var.aws_default_region}"
    }
    EOF
    destination = "/tmp/aws-creds.json"
  }

  # Upload setup script and provision AWS credentials
  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/tmp/setup.sh"
  }

  # Execute setup script with credentials
  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "sudo bash /tmp/setup.sh",
      "sudo rm -rf /tmp/setup.sh",
      "sudo rm -rf /tmp/aws-creds.json"
    ]
  }
}
