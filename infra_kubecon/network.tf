resource "aws_vpc" "kubecon_demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "kubecon-demo-vpc"
  }
}

resource "aws_internet_gateway" "kubecon_demo_gateway" {
  vpc_id = aws_vpc.kubecon_demo_vpc.id
}

resource "aws_subnet" "kubecon_demo_subnet" {
  vpc_id = aws_vpc.kubecon_demo_vpc.id

  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "kubecon-demo Public Subnet"
  }
}

resource "aws_route_table" "kubecon_demo_route_table" {
  vpc_id = aws_vpc.kubecon_demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubecon_demo_gateway.id
  }

  tags = {
    Name = "kubecon-demo Public Subnet"
  }
}

resource "aws_route_table_association" "kubecon_demo_route_table_association" {
  subnet_id      = aws_subnet.kubecon_demo_subnet.id
  route_table_id = aws_route_table.kubecon_demo_route_table.id
}

resource "aws_security_group" "kubecon_demo" {
  name   = "kubecon-demo"
  vpc_id = aws_vpc.kubecon_demo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 30001
    to_port     = 30001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9345
    to_port     = 9345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [aws_vpc.kubecon_demo_vpc.cidr_block]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}