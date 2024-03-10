// https://aws.amazon.com/ec2/instance-types/

resource "aws_instance" "nanda_big_instance" {
  ami           = "ami-034dd93fb26e1a731"
  instance_type = "t2.medium"
  subnet_id     = data.aws_subnet.default.id
  key_name  = data.aws_key_pair.nanda.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.outbound_all.id, 
    aws_security_group.inbound_ssh.id,
    aws_security_group.inbound_http_https.id,
    aws_security_group.inbound_wireshark.id
  ]

  tags = {
    Name = "nanda_big_instance"
  }
}

output ec2_nanda_big_instance_public_ip {
  value       = aws_instance.nanda_big_instance.public_ip
  sensitive   = true
  description = "nanda_instance public ip"
}

# resource "aws_instance" "nanda_instance" {
#   ami           = "ami-034dd93fb26e1a731"
#   instance_type = "t2.nano"
#   subnet_id     = data.aws_subnet.default.id
#   key_name  = data.aws_key_pair.nanda.key_name
#   associate_public_ip_address = true
#   vpc_security_group_ids = [
#     aws_security_group.outbound_all.id, 
#     aws_security_group.inbound_ssh.id,
#     aws_security_group.inbound_http_https.id, 
#     aws_security_group.inbound_wireshark.id
#   ]

#   tags = {
#     Name = "nanda_instance"
#   }
# }

# output ec2_nanda_instance_public_ip {
#   value       = aws_instance.nanda_instance.public_ip
#   sensitive   = true
#   description = "nanda_instance public ip"
# }
