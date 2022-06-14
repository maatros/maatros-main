# Configure the AWS provider
provider "aws" {
  region = "var.region"
}

# Create a Security Group for an EC2 instance
resource "aws_security_group" "SecurityGroup_EC2inPublicSubnet" {
  name = "Security Group for EC2 instances public subnets"
  #  aws_vpc = aws_vpc.my_vpc.id
  vpc_id = aws_vpc.my_vpc.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-publicsubnetEC2-SG"
  }
  depends_on = [aws_vpc.my_vpc]
}

# block "data" is needed to get Data about "aws_availability_zones" 
data "aws_availability_zones" "availableAZ" {}

# Creating VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"
  #   enable_dns_support               = true
  #   enable_dns_hostnames             = true
  #   assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "publicsubnet" {
  count                   = length(var.publicSubnetCIDR)
  cidr_block              = tolist(var.publicSubnetCIDR)[count.index]
  vpc_id                  = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.availableAZ.names[count.index]

  tags = {
    Name        = "${var.environment}-publicsubnet-${count.index + 1}"
    AZ          = data.aws_availability_zones.availableAZ.names[count.index]
    Environment = "${var.environment}-publicsubnet"
  }

  depends_on = [aws_vpc.my_vpc]
}

#Private subnet
resource "aws_subnet" "privatesubnet" {
  count             = length(var.publicSubnetCIDR)
  cidr_block        = tolist(var.privateSubnetCIDR)[count.index]
  vpc_id            = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.availableAZ.names[count.index]

  tags = {
    Name        = "${var.environment}-privatesubnet-${count.index + 1}"
    AZ          = data.aws_availability_zones.availableAZ.names[count.index]
    Environment = "${var.environment}-privatesubnet"
  }

  depends_on = [aws_vpc.my_vpc]
}

# To provide internet in/out access for our VPC 
# we should use "resource "aws_internet_gateway"" (AWS Internet Gateway service)
resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.environment}-InternetGateway"
  }

  depends_on = [aws_vpc.my_vpc]
}

#AWS Route Table
resource "aws_route_table" "publicroutetable" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }

  tags = {
    Name = "${var.environment}-publicroutetable"
  }

  depends_on = [aws_internet_gateway.internetgateway]
}

# Route Table Association - Public Routes
# resource "aws_route_table_association" is needed to determine subnets
# which  will be connected to the Internet Gateway and Public Routes
resource "aws_route_table_association" "routeTableAssociationPublicRoute" {
  count          = length(var.publicSubnetCIDR)
  route_table_id = aws_route_table.publicroutetable.id
  subnet_id      = aws_subnet.publicsubnet[count.index].id

  depends_on = [aws_subnet.publicsubnet, aws_route_table.publicroutetable]
}


# Create an EC2 instance
resource "aws_instance" "example" {
  ami                     = "ami-09d56f8956ab235b3"
  instance_type           = "t2.micro"
  vpc_security_group_ids = [aws_security_group.SecurityGroup_EC2inPublicSubnet.id]
  subnet_id              = aws_subnet.publicsubnet[count.index].id
  user_data               = filebase64("script.sh")
}

# Output variable: Public IP address
output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}