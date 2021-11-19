provider "aws" {
  region = local.region
}

locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.21"
  region          = "eu-west-1"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "../.."

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  self_managed_node_groups = {
    one = {
      name                    = "spot-1"
      override_instance_types = ["m5.large", "m5d.large", "m6i.large"]
      spot_instance_pools     = 4
      asg_max_size            = 5
      asg_desired_capacity    = 5
      bootstrap_extra_args    = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      public_ip               = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    # disk_size              = 50
    vpc_security_group_ids = [aws_security_group.additional.id]
    create_launch_template = true
  }

  eks_managed_node_groups = {
    blue = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      # taints = {
      #   dedicated = {
      #     key    = "dedicated"
      #     value  = "gpuGroup"
      #     effect = "NO_SCHEDULE"
      #   }
      # }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
      tags = {
        ExtraTag = "example"
      }
    }
    green = {}
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
        }
      ]

      tags = {
        Owner = "test"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  tags = local.tags
}

################################################################################
# Disabled creation
################################################################################

module "disabled_eks" {
  source = "../.."

  create = false
}

module "disabled_fargate_profile" {
  source = "../../modules/fargate-profile"

  create = false
}

module "disabled_eks_managed_node_group" {
  source = "../../modules/eks-managed-node-group"

  create = false
}

module "disabled_self_managed_node_group" {
  source = "../../modules/self-managed-node-group"

  create = false
}

################################################################################
# Kubernetes provider configuration
################################################################################

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   experiments {
#     manifest_resource = true
#   }
# }

# locals {
#   fargate_roles = [for k, v in module.eks.fargate_profiles :
#     {
#       rolearn  = v.iam_role_arn
#       username = "system:node:{{SessionName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#         "system:node-proxier",
#       ]
#     }
#   ]
#   linux_roles = [for k, v in module.eks.eks_managed_node_groups :
#     {
#       rolearn  = v.iam_role_arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#       ]
#     }
#   ]
# }

# data "http" "wait_for_cluster" {
#   url            = "${module.eks.cluster_endpoint}/healthz"
#   ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   timeout        = 300
# }

# resource "kubernetes_manifest" "aws_auth" {
#   manifest = {
#     apiVersion = "v1"
#     kind       = "ConfigMap"
#     metadata = {
#       name      = "aws-auth"
#       namespace = "kube-system"
#     }

#     data = {
#       mapRoles = yamlencode(concat(local.fargate_roles, local.linux_roles))
#     }
#   }

#   depends_on = [data.http.wait_for_cluster]
# }

################################################################################
# Supporting resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = local.tags
}

resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
