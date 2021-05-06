provider "aws" {
  region = "ap-south-1"
  profile = "default"
}


resource "aws_instance" "os1" {
  ami = "ami-010aff33ed5991201"
  instance_type = "t2.micro"
  tags = {
    Name="myos_terraform"
  }
}

resource "aws_ebs_volume" "vol" {
  availability_zone = aws_instance.os1.availability_zone
  size = 10
  tags={
    Name="My Terraform OS Volume"
  }
}

resource "aws_volume_attachment" "attachvol" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.os1.id
  volume_id = aws_ebs_volume.vol.id
}

output "id" {
  value = aws_instance.os1.id
}
output "ip" {
  value = aws_instance.os1.public_ip
}
output "idebs" {
  value = aws_ebs_volume.vol.id
}
