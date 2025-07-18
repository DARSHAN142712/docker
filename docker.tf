data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_instance" "docker" {
  ami                    = local.ami_id
  instance_type          = "t3.medium"
  subnet_id              = data.aws_subnet_ids.default.ids[0]  
  vpc_security_group_ids = [aws_security_group.allow_all_docker.id]

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = file("docker.sh")

  tags = {
    Name = "${var.project}-${var.environment}-docker"
  }
}

resource "aws_security_group" "allow_all_docker" {
  name        = "allow_all_docker"
  description = "allow all traffic"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "allow-all-docker"
  }
}
