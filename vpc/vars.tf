variable "main_vpc_cidr" {
  description = "cidr block for main vpc"
}
variable "publicSubnets" {
  description = "map of public subnets with the cidr block. Name shoould be public{subnet number}"
}
variable "privateSubnets" {
  description = "map of private subnets with the cidr block. Name shoould be private{subnet number}"
}