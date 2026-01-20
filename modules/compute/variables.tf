variable "sg_name" {
    type = string
}
variable "sg_desc" {
    type = string
}
variable "sg_cidr_blocks" {
    type = list(string)
}
variable "ami_id" {
    type = string
}
variable "instance_type" {
    type = string
}
variable "key_name" {
    type = string
}
variable "disk_size" {
    type = number
}
variable "instance_name" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "subnet_id" {
    type = string
}
