# Self-managed Node Group

Refer to the [Self Managed Node Group documentation](https://docs.aws.amazon.com/eks/latest/userguide/worker.html) documentation for service related details.

1. The `self-managed-node-group` uses the latest AWS EKS Optimized AMI (Linux) for the given Kubernetes version by default:

```hcl
  cluster_version = "1.27"

  # This self managed node group will use the latest AWS EKS Optimized AMI for Kubernetes 1.27
  self_managed_node_groups = {
    default = {}
  }
```

2. To use Bottlerocket, specify the `ami_type` as one of the respective `"BOTTLEROCKET_*" types` and supply a Bottlerocket OS AMI:

```hcl
  cluster_version = "1.27"

  self_managed_node_groups = {
    bottlerocket = {
      ami_id   = data.aws_ami.bottlerocket_ami.id
      ami_type = "BOTTLEROCKET_x86_64"
    }
  }
```

See the [`examples/self_managed_node_group/` example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/self_managed_node_group) for a working example of various configurations.

## Examples

### Amazon Linux 2

```terraform
{% include  "../../examples/self-managed-node-group/eks-al2.tf" %}
```

### Amazon Linux 2023

```terraform
{% include  "../../examples/self-managed-node-group/eks-al2023.tf" %}
```

### Amazon Bottlerocket

```terraform
{% include  "../../examples/self-managed-node-group/eks-bottlerocket.tf" %}
```
