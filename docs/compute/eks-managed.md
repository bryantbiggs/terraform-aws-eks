# EKS Managed Node Group

Please refer to the [EKS Managed Node Group documentation](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) for service related details.

See [`examples/eks-managed_node-group/`](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks-managed-node-group) for examples of various configurations.

## Configuration

By default, this module creates and utilizes custom launch template to to support common configurations not supported with the default EKS managed node group launch template. This ensures tags are propagated to instances launched, that users have the ability to add/modify the security group(s) used by nodes and their rules, as well as the ability to provide user data. Please note that many of the customization options listed [here](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/eks-managed-node-group#Inputs) are only available when a custom launch template is utilized. To use the default template provided by the AWS EKS managed node group service, disable the launch template creation by setting `use_custom_launch_template` to `false`:

```hcl
  eks_managed_node_groups = {
    default = {
      use_custom_launch_template = false
    }
  }
```

!!! warning
    It is not recommended to disable the use of the custom launch template with this module.

## AMIs

This module supports all EKS managed node group [AMI types](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-eks-nodegroup.html#cfn-eks-nodegroup-amitype).

When using a custom AMI, the AWS EKS Managed node group service will *NOT* inject the necessary configuration into the supplied user data. Instead, users will need to provide their own user data to connect nodes to the cluster or opt in to use the module provided user data:

!!! warning
    The use of a custom AMI is detected by EKS managed node group when either `ami_type = "CUSTOM"` is specified, or a value is provided to the `ami_id` argument (or both). This means that if you use a data source to look up the EKS AL2 AMI and pass the returned AMI ID output to the `ami_id` argument, the EKS managed node group will still treat this as a custom AMI and it will *NOT* inject the necessary configuration into the user data.

    If you are using an EKS provided AMI, do not use the `ami_id` argument and instead use the `ami_type` and optionally the `ami_release_version`/`use_latest_ami_release_version` arguments.

This module provides the `enable_bootstrap_user_data = true` argument to add the necessary configuration back into the user data for custom AMIs. You can modify the behavior of what user data format is used by setting the `ami_type` to match the AMI derivative you are using (i.e. - when starting with an EKS AMI as a base AMI and modifying). If the AMI is completely custom and not using the EKS provisions for bootstrapping and joining nodes to the cluster, you can use the `user_data_template_path` argument to provide the file path to a local file that contains the user data template that will be used.

### EKS AL2 AMI Derivative

When using a custom AMI that is based on the EKS AL2 AMI, the module provides a way to add the necessary configuration back into the user data. This is done by setting `enable_bootstrap_user_data = true` and providing any additional user data in the `pre_bootstrap_user_data`/`post_bootstrap_user_data` arguments. The EKS AL2 AMI derivatives use the standard shell script user data format.

!!! info
    `post_bootstrap_user_data` is only valid on custom AMIs with EKS managed node groups

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  eks_managed_node_groups = {
    al2_custom_ami = {
      ami_type = "AL2_x86_64"
      ami_id   = "ami-0caf35bc73450c396"

      # This assumes the AMI provided is an EKS AL2 optimized AMI
      # derivative as identified by `ami_type = "AL2_x86_64"`
      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = <<-EOT
        export FOO=bar
      EOT

      post_bootstrap_user_data = <<-EOT
        echo "Complete!"
      EOT
    }
  }
}
```

### EKS AL2023 AMI Derivative

The EKS AL2023 AMI derivatives use the MIME multi-part user data format. Users can supply [`nodeadm` configuration](https://awslabs.github.io/amazon-eks-ami/nodeadm/) that is merged with the default `nodeadm` settings.

!!! info
    `cloudinit_post_nodeadm` is only valid on custom AMIs with EKS managed node groups

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  eks_managed_node_groups = {
    al2023_custom_ami = {
      ami_type = "AL2023_x86_64_STANDARD"
      ami_id   = "ami-0caf35bc73450c396"

      # This assumes the AMI provided is an EKS AL2 optimized AMI
      # derivative as identified by `ami_type = "AL2023_x86_64_STANDARD"`
      enable_bootstrap_user_data = true

      cloudinit_pre_nodeadm = [{
        content_type = "application/node.eks.aws"
        content      = <<-EOT
          ---
          apiVersion: node.eks.aws/v1alpha1
          kind: NodeConfig
          spec:
            kubelet:
              config:
                shutdownGracePeriod: 30s
                featureGates:
                  DisableKubeletCloudCredentialProviders: true
        EOT
      }]

      cloudinit_post_nodeadm = [{
        content_type = "text/x-shellscript"
        content      = <<-EOT
          echo "Complete!"
        EOT
      }]
    }
  }
}
```

## Examples

### Amazon Linux 2

```terraform
{% include  "../../examples/eks-managed-node-group/eks-al2.tf" %}
```

### Amazon Linux 2023

```terraform
{% include  "../../examples/eks-managed-node-group/eks-al2023.tf" %}
```

### Amazon Bottlerocket

```terraform
{% include  "../../examples/eks-managed-node-group/eks-bottlerocket.tf" %}
```
