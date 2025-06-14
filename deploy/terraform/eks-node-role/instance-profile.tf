resource "aws_iam_instance_profile" "profile" {
  name = var.name
  role = aws_iam_role.eks_node_role.name

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}
