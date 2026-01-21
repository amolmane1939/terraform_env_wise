variable "region" {
  description = "The region to deploy to"
  type        = string
}
variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "private_subnet_1_cidr" {
  type = string
}
variable "private_subnet_1_name" {
  type = string
}

variable "public_subnet_1_cidr" {
  type = string
}

variable "public_subnet_1_name" {
  type = string
}

variable "igw_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "availability_zone" {
  type = list(string)
}

variable "public_rt_name" {
  type = string
}