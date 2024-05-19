data "aws_key_pair" "nanda" {
  key_name           = "Nanda Personal AWS Key"
  include_public_key = true
}

resource "aws_key_pair" "project_sprint" {
  count      = var.projectsprint_start ? 1 : 0
  key_name   = "projectsprint"
  public_key = var.projectsprint_vm_public_key
}