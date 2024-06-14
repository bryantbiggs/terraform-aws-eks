provider "aws" {
  region = "us-west-2"
}

locals {
  name = "ex-${basename(path.cwd)}"

  outpost_arn   = element(tolist(data.aws_outposts_outposts.this.arns), 0)
  instance_type = element(tolist(data.aws_outposts_outpost_instance_types.this.instance_types), 0)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Supporting Resources
################################################################################

data "aws_outposts_outposts" "this" {}

data "aws_outposts_outpost_instance_types" "this" {
  arn = local.outpost_arn
}

# This just grabs the first Outpost and returns its subnets
data "aws_subnets" "lookup" {
  filter {
    name   = "outpost-arn"
    values = [local.outpost_arn]
  }
}

# This grabs a single subnet to reverse lookup those that belong to same VPC
# This is whats used for the cluster
data "aws_subnet" "this" {
  id = element(tolist(data.aws_subnets.lookup.ids), 0)
}

# These are subnets for the Outpost and restricted to the same VPC
# This is whats used for the cluster
data "aws_subnets" "this" {
  filter {
    name   = "outpost-arn"
    values = [local.outpost_arn]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.this.vpc_id]
  }
}

data "aws_vpc" "this" {
  id = data.aws_subnet.this.vpc_id
}
