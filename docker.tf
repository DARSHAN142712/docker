# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get a subnet from the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group that allows all traffic
resource "aws_security_group" "allow_all_docker" {
  name        = "allow_all_docker"
  description = "Allow all inbound and outbound traffic"

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

# EC2 instance in default VPC subnet, with public IP
resource "aws_instance" "docker" {
  ami                         = local.ami_id              # Make sure local.ami_id is defined elsewhere
  instance_type               = "t3.medium"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.allow_all_docker.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = file("docker.sh") # Make sure docker.sh exists in your project directory

  tags = {
    Name = "${var.project}-${var.environment}-docker"
  }
}

# Optional: output public IP after creation
output "docker_instance_public_ip" {
  value       = aws_instance.docker.public_ip
  description = "Public IP of the EC2 instance running Docker"
}
