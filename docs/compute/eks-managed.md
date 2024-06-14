# EKS Managed Node Group

Refer to the [EKS Managed Node Group documentation](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) for service related details.

## Configuration

By default, the module creates a custom launch template to ensure settings such as tags are propagated to instances. Please note that many of the customization options listed [here](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/modules/eks-managed-node-group#Inputs) are only available when a custom launch template is utilized. To use the default template provided by the AWS EKS managed node group service, disable the launch template creation by setting `use_custom_launch_template` to `false`:

```hcl
  eks_managed_node_groups = {
    default = {
      use_custom_launch_template = false
    }
  }
```

2. Native support for Bottlerocket OS is provided by providing the respective AMI type:

```hcl
  eks_managed_node_groups = {
    bottlerocket_default = {
      use_custom_launch_template = false

      ami_type = "BOTTLEROCKET_x86_64"
    }
  }
```

3. Bottlerocket OS is supported in a similar manner. However, note that the user data for Bottlerocket OS uses the TOML format:

```hcl
  eks_managed_node_groups = {
    bottlerocket_prepend_userdata = {
      ami_type = "BOTTLEROCKET_x86_64"

      bootstrap_extra_args = <<-EOT
        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    }
  }
```

4. When using a custom AMI, the AWS EKS Managed Node Group service will NOT inject the necessary bootstrap script into the supplied user data. Users can elect to provide their own user data to bootstrap and connect or opt in to use the module provided user data:

```hcl
  eks_managed_node_groups = {
    custom_ami = {
      ami_id = "ami-0caf35bc73450c396"

      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      enable_bootstrap_user_data = true

      pre_bootstrap_user_data = <<-EOT
        export FOO=bar
      EOT

      # Because we have full control over the user data supplied, we can also run additional
      # scripts/configuration changes after the bootstrap script has been run
      post_bootstrap_user_data = <<-EOT
        echo "you are free little kubelet!"
      EOT
    }
  }
```

5. There is similar support for Bottlerocket OS:

```hcl
  eks_managed_node_groups = {
    bottlerocket_custom_ami = {
      ami_id   = "ami-0ff61e0bcfc81dc94"
      ami_type = "BOTTLEROCKET_x86_64"

      # Have the module supply the user data since the use of a custom AMI
      # means that EKS managed node group will not supply user data
      enable_bootstrap_user_data = true

      # this will get added to the template
      bootstrap_extra_args = <<-EOT
        [settings.kernel]
        lockdown = "integrity"

        [settings.kubernetes.node-taints]
        "dedicated" = "experimental:PreferNoSchedule"
        "special" = "true:NoSchedule"
      EOT
    }
  }
```

See the [`examples/eks_managed_node_group/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_managed_node_group) for a working example of various configurations.

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
