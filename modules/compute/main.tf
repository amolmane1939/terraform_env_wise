resource "aws_security_group" "dev_sg" {
    name = var.sg_name
    description = var.sg_desc
    vpc_id = var.vpc_id
    tags = {
        Name = var.sg_name    }
}
resource "aws_security_group_rule" "ingress_rule" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    security_group_id = aws_security_group.dev_sg.id
}

resource "aws_security_group_rule" "ingress_rule1" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.sg_cidr_blocks
    security_group_id = aws_security_group.dev_sg.id
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  root_block_device {
    volume_size = var.disk_size
    delete_on_termination = true
    encrypted = true
    volume_type = "gp3"
  }
  tags = {
    Name = var.instance_name
  }
}
