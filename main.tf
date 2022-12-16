# After creating resources with Terraform: 
# Run 'terraform show' to get the details of the running resources.
# Run 'terraform destroy' to terminate the resources.

# Creating a VPC with the name devenv_vpc.
resource "aws_vpc" "devenv_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "devenv_vpc"
  }
}

# Creating a public subnet in the VPC.
resource "aws_subnet" "devenv_public_subnet" {
  vpc_id                  = aws_vpc.devenv_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    "Name" = "devenv_public_subnet"
  }
}

# Creating an internet gateway for the VPC.
resource "aws_internet_gateway" "devenv_igw" {
  vpc_id = aws_vpc.devenv_vpc.id

  tags = {
    "Name" = "devenv_igw"
  }
}

# Creating a route table for the VPC.
resource "aws_route_table" "devenv_public_rt" {
  vpc_id = aws_vpc.devenv_vpc.id

  tags = {
    "Name" = "devenv_public_rt"
  }
}

# Creating a route for the route table.
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.devenv_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devenv_igw.id
}

# Associating the route table with the subnet.
resource "aws_route_table_association" "devenv_public_rt_assoc" {
  subnet_id      = aws_subnet.devenv_public_subnet.id
  route_table_id = aws_route_table.devenv_public_rt.id
}

# Creating a security group for the VPC.
resource "aws_security_group" "devenv_sg" {
  name        = "devenv_sg"
  description = "Developer environment security group."
  vpc_id      = aws_vpc.devenv_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating a key pair for the EC2 instance.
resource "aws_key_pair" "devenv_auth" {
  key_name   = "devenv_key"
  public_key = file("~/.ssh/devenv_key.pub")

}

# Creating an EC2 instance.
resource "aws_instance" "devenv_instance" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.devenv_ec2_ami.id
  key_name               = aws_key_pair.devenv_auth.key_name
  vpc_security_group_ids = [aws_security_group.devenv_sg.id]
  subnet_id              = aws_subnet.devenv_public_subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "devenv_instance"
  }

  # Creating a ssh config file.
  # If the instance already exists, use "terraform apply -replace aws_instance.devenv_instance"
  provisioner "local-exec" {
    command = templatefile("ssh_config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/devenv_key"
    })
  }
}
