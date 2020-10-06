provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "kenichi-mac"
  vpc_security_group_ids = [aws_security_group.web_flask.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update ",
      "sudo apt-get install -y python3-pip nginx",
      "python3 --version",
      "pip3 --version",
      "sudo systemctl start nginx",
      "sudo pip3 install pipenv",
      "git clone https://github.com/kenichi-shibata/kumusta-mundo.git",
      "cd kumusta-mundo",
      "pipenv shell --python /usr/bin/python3",
      "pipenv install --python /usr/bin/python3",
      "gunicorn -w 2 -b 0.0.0.0:5000 --chdir kumusta-mundo/ hello-world:app"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
    }


  }
  tags = {
    Name = "kshibata-cloud"
    Owner = "kshibata"
    Environment = "Development"
  }
}

resource "aws_security_group" "web_flask" {
  name        = "web_flask"
  description = "web flask"
  vpc_id      = data.aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

