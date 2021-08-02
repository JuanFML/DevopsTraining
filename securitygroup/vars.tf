variable "instance-port"{
  description = "port of the instance for the load balancer"
  type = string
}
variable "security-group-name" {
  description = "name of the secuirty-group"
  type = string
}
variable "security-group-lb-name" {
  description = "name of the secuirty-group"
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
variable "ingress-lb-configs" {
    description = "multiple configurations for ingress rule"
    type= map

}