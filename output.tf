output "ip-ec2" {
  value = aws_instance.testmysql.public_ip
}
output "db_address" {
  value = aws_db_instance.default.address
}