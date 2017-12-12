# creating a new vpc with dns resolution support
resource "aws_vpc" "vpc_guilherme" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "Guilherme VPC"
    BuildWith = "terraform"
  }
}

# adding public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${ aws_vpc.vpc_guilherme.id }"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name      = "Public Subnet"
    BuildWith = "terraform"
  }
}

# adding private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = "${ aws_vpc.vpc_guilherme.id }"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name      = "Private Subnet"
    BuildWith = "terraform"
  }
}

# adding internet gateway for external communication
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${ aws_vpc.vpc_guilherme.id }"

  tags = {
    Name      = "Internet Gateway"
    BuildWith = "terraform"
  }
}

# create external route to IGW
resource "aws_route" "external_route" {
  route_table_id         = "${ aws_vpc.vpc_guilherme.main_route_table_id }"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${ aws_internet_gateway.internet_gateway.id }"
}

# adding an elastic IP
resource "aws_eip" "elastic_ip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

# creating the NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = "${ aws_eip.elastic_ip.id }"
  subnet_id     = "${ aws_subnet.public_subnet.id }"
  depends_on    = ["aws_internet_gateway.internet_gateway"]
}

# creating private route table 
resource "aws_route_table" "private_route_table" {
  vpc_id = "${ aws_vpc.vpc_guilherme.id }"

  tags {
    Name      = "Private Subnet Route Table"
    BuildWith = "terraform"
  }
}

# adding private route table to nat
resource "aws_route" "private_route" {
  route_table_id         = "${ aws_route_table.private_route_table.id }"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${ aws_nat_gateway.nat.id }"
}

# associate subnet public to public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = "${ aws_subnet.public_subnet.id }"
  route_table_id = "${ aws_vpc.vpc_guilherme.main_route_table_id }"
}

# associate subnet private subnet to private route table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = "${ aws_subnet.private_subnet.id }"
  route_table_id = "${ aws_route_table.private_route_table.id }"
}
