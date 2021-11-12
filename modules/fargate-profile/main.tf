data "aws_partition" "current" {}

locals {
  iam_role_name     = coalesce(var.iam_role_name, var.fargate_profile_name)
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}

################################################################################
# IAM Role
################################################################################

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create && var.create_iam_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create && var.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create && var.create_iam_role ? toset(compact(distinct(concat([
    "${local.policy_arn_prefix}/AmazonEKSFargatePodExecutionRolePolicy",
  ], var.iam_role_additional_policies)))) : toset([])

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

################################################################################
# Fargate Profile
################################################################################

resource "aws_eks_fargate_profile" "this" {
  for_each = var.create ? 1 : 0

  cluster_name           = var.cluster_name
  fargate_profile_name   = var.fargate_profile_name
  pod_execution_role_arn = var.create_iam_role ? aws_iam_role.this[0].arn : var.iam_role_arn
  subnet_ids             = var.subnet_ids

  dynamic "selector" {
    for_each = var.selectors

    content {
      namespace = selector.value.namespace
      labels    = lookup(selector.value, "labels", {})
    }
  }

  dynamic "timeouts" {
    for_each = [var.timeouts]
    content {
      create = lookup(var.timeouts, "create", null)
      delete = lookup(var.timeouts, "delete", null)
    }
  }

  tags = var.tags
}
