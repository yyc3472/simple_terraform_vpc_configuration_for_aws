# 2.internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform_vpc.id


}
# 3.route table

resource "aws_route_table" "terraform_routetable" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod-routetable"
  }
}

# 4. Create a subnet


resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet_1"
  }
}

# 5. Associate Subnet with route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.terraform_routetable.id
}



#7 Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "terraform_servernic" {
  subnet_id       = aws_subnet.subnet_1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

#8 Assign elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.terraform_servernic.id
  associate_with_private_ip = "10.0.1.50"

  depends_on = [aws_internet_gateway.gw]
}
