# Amazon Elastic Fabric Adapter (EFA)

## Enabling EFA Support

When enabling EFA support via `enable_efa_support = true`, there are two locations this can be specified - one at the cluster level, and one at the node group level. Enabling at the cluster level will add the EFA required ingress/egress rules to the shared security group created for the node group(s). Enabling at the node group level will do the following (per node group where enabled):

1. All EFA interfaces supported by the instance will be exposed on the launch template used by the node group
2. A placement group with `strategy = "clustered"` per EFA requirements is created and passed to the launch template used by the node group
3. Data sources will reverse lookup the availability zones that support the instance type selected based on the subnets provided, ensuring that only the associated subnets are passed to the launch template and therefore used by the placement group. This avoids the placement group being created in an availability zone that does not support the instance type selected.

!!! tip
    Use the [aws-efa-k8s-device-plugin](https://github.com/aws/eks-charts/tree/master/stable/aws-efa-k8s-device-plugin) Helm chart to expose the EFA interfaces on the nodes as an extended resource, and allow pods to request the interfaces be mounted to their containers.

    The EKS AL2 GPU AMI comes with the necessary EFA components pre-installed - you just need to expose the EFA devices on the nodes via their launch templates, ensure the required EFA security group rules are in place, and deploy the `aws-efa-k8s-device-plugin` in order to start utilizing EFA within your cluster. Your application container will need to have the necessary libraries and runtime in order to utilize communication over the EFA interfaces (NCCL, aws-ofi-nccl, hwloc, libfabric, aws-neuornx-collectives, CUDA, etc.).

If you disable the creation and use of the managed node group custom launch template (`create_launch_template = false` and/or `use_custom_launch_template = false`), this will interfere with the EFA functionality provided. In addition, if you do not supply an `instance_type` for self-managed node group(s), or `instance_types` for the managed node group(s), this will also interfere with the functionality. In order to support the EFA functionality provided by `enable_efa_support = true`, you must utilize the custom launch template created/provided by this module, and supply an `instance_type`/`instance_types` for the respective node group.

The logic behind supporting EFA uses a data source to lookup the instance type to retrieve the number of interfaces that the instance supports in order to enumerate and expose those interfaces on the launch template created. For managed node groups where a list of instance types are supported, the first instance type in the list is used to calculate the number of EFA interfaces supported. Mixing instance types with varying number of interfaces is not recommended for EFA (or in some cases, mixing instance types is not supported - i.e. - p5.48xlarge and p4d.24xlarge). In addition to exposing the EFA interfaces and updating the security group rules, a placement group is created per the EFA requirements and only the availability zones that support the instance type selected are used in the subnets provided to the node group.

In order to enable EFA support, you will have to specify `enable_efa_support = true` on both the cluster and each node group that you wish to enable EFA support for:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # Truncated for brevity ...

  # Adds the EFA required security group rules to the shared
  # security group created for the node group(s)
  enable_efa_support = true

  eks_managed_node_groups = {
    example = {
      instance_types = ["p5.48xlarge"]

      # Exposes all EFA interfaces on the launch template created by the node group(s)
      # This would expose all 32 EFA interfaces for the p5.48xlarge instance type
      enable_efa_support = true

      pre_bootstrap_user_data = <<-EOT
        # Mount NVME instance store volumes since they are typically
        # available on instance types that support EFA
        setup-local-disks raid0
      EOT

      # EFA should only be enabled when connecting 2 or more nodes
      # Do not use EFA on a single node workload
      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }
}
```
