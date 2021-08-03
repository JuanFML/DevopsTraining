output "security-group-id" {
  value = aws_security_group.Allow-http-ssh.id
}
output "lb-security-group-id" {
  value = aws_security_group.Allow-http.id
}