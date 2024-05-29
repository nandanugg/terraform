# resource "aws_service_discovery_service" "projectsprint_k6_service_discovery" {
#   count                       = var.projectsprint_start_load_test ? 1 : 0
#   name = "k6_service"
#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.projectsprint_dns_namespace.id

#     dns_records {
#       type = "A"
#       ttl  = 10
#     }
#   }
#   health_check_custom_config {
#     failure_threshold = 1
#   }
#   force_destroy = true
# }



resource "aws_instance" "projectsprint_k6" {
  count                       = var.projectsprint_start_load_test ? 1 : 0
  ami                         = "ami-003c463c8207b4dfa"
  instance_type               = "t3a.large"
  subnet_id                   = data.aws_subnet.b.id
  key_name                    = aws_key_pair.project_sprint[0].key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    module.projectsprint_ssh_sg.security_group_id,
    module.projectsprint_50051_sg.security_group_id,
  ]
  #   provisioner "local-exec" {
  #     when    = destroy
  #     command = <<EOF
  # aws servicediscovery deregister-instance --service-id ${aws_service_discovery_service.projectsprint_k6_service_discovery0[0].id} \
  # --instance-id "${aws_instance.projectsprint_k6[0].id}"
  # EOF
  #   }

  tags = {
    Name = "projectsprint-k6"
  }
}

# resource "null_resource" "register_instance" {
#   triggers = {
#     instance_id = aws_instance.projectsprint_k6[0].id
#   }

#   provisioner "local-exec" {
#     command = <<EOF
# aws servicediscovery register-instance --service-id ${aws_service_discovery_service.projectsprint_k6_service_discovery[0].id} \
# --instance-id "${aws_instance.projectsprint_k6[0].id}" \
# --attributes "AWS_INSTANCE_IPV4=${aws_instance.projectsprint_k6[0].private_ip}"
# EOF
#   }
# }
