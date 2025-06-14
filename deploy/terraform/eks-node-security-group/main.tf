resource "aws_security_group" "node_sg" {
  description = format("The security group for the EKS node group %s", var.node_group_name)

  name                   = var.node_group_name
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = merge(
    var.tags,
    { Name = var.node_group_name },
    { format("kubernetes.io/cluster/%s", var.cluster_name) = "owned" }
  )

}

# -------------------------------------
# Cluster's security group rules
# -------------------------------------
resource "aws_security_group_rule" "ingress_cluster_from_node_443" {
  description = format("Allow inbound HTTPS traffic from the node group %s to the cluster.", var.node_group_name)

  type      = "ingress"
  protocol  = "tcp"
  from_port = 443
  to_port   = 443

  source_security_group_id = aws_security_group.node_sg.id
  security_group_id        = var.cluster_security_group_id
}

resource "aws_security_group_rule" "egress_cluster_to_node" {
  description = format("Allow outbound TCP traffic from the cluster to the node group %s on the recommended ports.", var.node_group_name)

  type      = "ingress"
  protocol  = "tcp"
  from_port = 1025
  to_port   = 65535

  source_security_group_id = aws_security_group.node_sg.id
  security_group_id        = var.cluster_security_group_id
}

# -------------------------------------
# Node's security group rules
# -------------------------------------
resource "aws_security_group_rule" "ingress_node_from_cluster_443" {
  description = "Allow inbound HTTPS traffic from the cluster to the nodes."

  type      = "ingress"
  protocol  = "tcp"
  from_port = 443
  to_port   = 443

  source_security_group_id = var.cluster_security_group_id
  security_group_id        = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "ingress_node_from_cluster" {
  description = "Allow inbound TCP traffic from the cluster to the nodes on the recommended ports."

  type      = "ingress"
  protocol  = "tcp"
  from_port = 1025
  to_port   = 65535

  source_security_group_id = var.cluster_security_group_id
  security_group_id        = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "egress_node" {
  description = "Allow outbound TCP traffic from the nodes."

  type        = "egress"
  protocol    = "all"
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "ingress_node" {
  description = "Allow ingress TCP traffic from the nodes."

  type        = "ingress"
  protocol    = "all"
  from_port   = 0
  to_port     = 0
  cidr_blocks = [data.aws_vpc.main.cidr_block]

  security_group_id = aws_security_group.node_sg.id
}
