output "vpc_id" {
  value = aws_vpc.main.id
}
output "private_subnet_id" {
  value = aws_subnet.private_subnet_1.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet_1.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}
