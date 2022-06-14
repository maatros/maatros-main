# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a Security Group for an EC2 instance
resource "aws_security_group" "instance" {
  name = "Terraform WWW"
  
  ingress {
    from_port	  = 8080
    to_port	    = 8080
    protocol	  = "tcp"
    cidr_blocks	= ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami                     = "ami-09d56f8956ab235b3"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.instance.id}"]
  user_data               = filebase64("script.sh")
}

# Output variable: Public IP address
output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}