output "publicSubnets_ids" {
  value = values(aws_subnet.publicSubnets)[*].id
}
output "publicSubnets1_id" {
  value = aws_subnet.publicSubnets["public1"].id
}
output "main_vpc_id" {
  value = aws_vpc.Main.id
}