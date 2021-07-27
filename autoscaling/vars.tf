
variable "AMI_id" {
  description = "the id of the image created"
}
variable "user_data64_file" {
  description = "the string file name"
}
variable "subnets" {
  description = "All the public subnets"
}

variable "main_vpc_id" {
  description = "Id of the main vpc"
}
variable "internal-load-balancer"{
  description = "Boolean to check if the load balancer is internal"
}
variable "instance-port"{
  description = "port of the instance for the load balancer"
}
variable "instance-name" {
  description = "name of the instance"
}