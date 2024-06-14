# Terraform AWS EKS module

Terraform module for creating Amazon EKS clusters.

```terraform
{% include  "../examples/eks-managed-node-group/eks-minimal.tf" %}
```

## Configuration

### Default Configurations

Each type of compute resource (EKS managed node group, self managed node group, or Fargate profile) provides the option for users to specify a default configuration. These default configurations can be overridden from within the compute resource's individual definition. The order of precedence for configurations (from highest to least precedence):

- Compute resource individual configuration
  - Compute resource family default configuration (`eks_managed_node_group_defaults`, `self_managed_node_group_defaults`, `fargate_profile_defaults`)
    - Module default configuration (see `variables.tf` and `node_groups.tf`)

For example, the following creates 4 AWS EKS Managed Node Groups:

```hcl
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # Uses module default configurations overridden by configuration above
    default = {}

    # This further overrides the instance types used
    compute = {
      instance_types = ["c5.large", "c6i.large", "c6d.large"]
    }

    # This further overrides the instance types and disk size used
    persistent = {
      disk_size = 1024
      instance_types = ["r5.xlarge", "r6i.xlarge", "r5b.xlarge"]
    }

    # This overrides the OS used
    bottlerocket = {
      ami_type = "BOTTLEROCKET_x86_64"
    }
  }
```
