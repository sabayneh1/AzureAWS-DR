output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id, aws_subnet.public_c.id]
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "public_subnet_c_id" {
  value = aws_subnet.public_c.id
}

output "security_group_id" {
  value = aws_security_group.my_sg.id
}
