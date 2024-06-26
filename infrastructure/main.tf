resource "aws_key_pair" "example" {
  key_name   = "key_ec2_with_docker"
  public_key = file("~/.ssh/lab.pub")
}

data "aws_ami" "amazon-ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["*images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}
resource "aws_security_group" "instance" {
  name = "security-group-ec2-docker"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = data.aws_vpc.default.id
}


resource "aws_instance" "example" {
  count                  = 1
  key_name               = aws_key_pair.example.key_name
  ami                    = data.aws_ami.amazon-ubuntu.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = data.template_file.userdata.rendered
  root_block_device {
    volume_size = 20
  }
}
data "template_file" "userdata" {
  template = file("${path.module}/userdata.tpl")
}
