variable "instance-port"{
  description = "port of the instance for the load balancer"
  type = string
}
variable "instance-name" {
  description = "name of the instance"
  type = string
}
variable "main_vpc_id" {
  description = "Id of the main vpc"
  type = string
}
variable "ingress-configs" {
    description = "multiple configurations for ingress rule"
    type= map

}