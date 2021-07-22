variable "vpc_identifier" {
  description = "vpc zone identifier, this has to be a set"
}
variable "AMI_id" {
  description = "the id of the image created"
}
variable "user_data64_file" {
  description = "the string file name"
}
variable "publicSubnets" {
  description = "All the public subnets"
}
variable "main_vpc_id" {
  description = "Id of the main vpc"
}
