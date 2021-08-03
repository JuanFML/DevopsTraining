output "publicSubnets_ids" {
  value = aws_subnet.publicSubnets[*].id
}
output "privateSubnets_ids" {
  value = aws_subnet.privateSubnets[*].id
}
output "main_vpc_id" {
  value = aws_vpc.Main.id
}