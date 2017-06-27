variable "service_port" {
  description = "The port the server will use for HTTP requests"
}

variable "vpc_id" {
  description = "vpc id"
}

variable "vpc_name" {
  description = "vpc name"
}

variable "internal_subnet_id" {
  description = "internal_subnet_id"
}

variable "external_subnet_id" {
  description = "external_subnet_id"
}

variable "instance_type" {
  description = "instance size"
  default = "t2.micro"
}

variable "min_size" {
  description = "min num instances in ASG"
  default = 1
}

variable "max_size" {
  description = "min num instances in ASG"
  default = 1
}

variable "service_image_id" {}