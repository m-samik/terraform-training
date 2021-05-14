provider "aws" {
  region = "ap-south-1"
  profile = "default"
}

resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "Allow HTTPD inbound traffic"

  ingress {
    description = "All Traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
    ipv6_cidr_blocks = [
      "::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
    ipv6_cidr_blocks = [
      "::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "httpd" {
  ami = "ami-010aff33ed5991201"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_http.name]
  key_name = "myawskey"
  tags = {
    Name ="Terraform OS"
  }
  }

resource "aws_ebs_volume" "myhd" {
  availability_zone = aws_instance.httpd.availability_zone
  size=1
  tags = {
    Name ="HD Terraform"
  }
}

resource "aws_volume_attachment" "attachmyhd" {
  depends_on = [
    aws_ebs_volume.myhd
  ]
  device_name = "/dev/sdh"
  instance_id = aws_instance.httpd.id
  volume_id = aws_ebs_volume.myhd.id
}

resource "null_resource" "null" {
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("")
    host = aws_instance.httpd.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git  -y",
      "sudo systemctl enable httpd --now"
    ]
  }
}

resource "null_resource" "null2" {
  depends_on = [
    aws_volume_attachment.attachmyhd
  ]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("")
    host = aws_instance.httpd.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/sdh",
      "sudo mount  /dev/sdh  /var/www/html"]
  }
}

resource "null_resource" "null_3" {
  depends_on = [
    null_resource.null2
  ]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("")
    host = aws_instance.httpd.public_ip
  }
  provisioner "remote-exec" {
    inline=[
      #"sudo rm -rvf /var/www/html/*",
      "sudo git clone https://github.com/m-samik/test.git /var/www/html"
      ]
  }
}

resource "null_resource" "opening_firefox" {
  provisioner "local-exec" {
    command= "google-chrome http://${aws_instance.httpd.public_ip}/"
  }
}



