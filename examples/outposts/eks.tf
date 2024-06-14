################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.30"

  cluster_endpoint_public_access  = false # Not available on Outpost
  cluster_endpoint_private_access = true

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (EBS storage class) into the cluster
  enable_cluster_creator_admin_permissions = true

  vpc_id     = data.aws_vpc.this.id
  subnet_ids = data.aws_subnets.this.ids

  outpost_config = {
    control_plane_instance_type = local.instance_type
    outpost_arns                = [local.outpost_arn]
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_vpc_https = {
      description = "Remote host to control plane"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [data.aws_vpc.this.cidr_block]
    }
  }

  self_managed_node_groups = {
    outpost = {
      name = local.name

      min_size      = 2
      max_size      = 5
      desired_size  = 3
      instance_type = local.instance_type

      # Additional information is required to join local clusters to EKS
      bootstrap_extra_args = <<-EOT
        --enable-local-outpost true --cluster-id ${module.eks.cluster_id} --container-runtime containerd
      EOT
    }
  }

  tags = local.tags
}

resource "kubernetes_storage_class_v1" "this" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp2"
    encrypted = "true"
  }
}
