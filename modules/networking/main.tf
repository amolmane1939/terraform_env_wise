#create vpc
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    tags = {
        Name = var.vpc_name
    }
}

#create subnets
resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_1_cidr
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = false
    tags = {
        Name = var.private_subnet_1_name
    }
}

#create public subnet
resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_1_cidr
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true
    tags = {
        Name = var.public_subnet_1_name
    }
}

#creating internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = var.igw_name
    }
}

#creating route table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = var.public_rt_name
    }
}

#route table association
resource "aws_route_table_association" "public_subnet_1_rt_association" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_rt.id
}
