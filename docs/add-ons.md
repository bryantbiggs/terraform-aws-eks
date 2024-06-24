# Amazon EKS add-ons

## Available EKS add-ons

Available EKS add-ons are listed [in the EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html#workloads-add-ons-available-eks) . You can also use the AWS CLI to retrieve the list of available add-ons by name:

```bash
aws eks describe-addon-versions --query 'addons[*].addonName' --region us-east-1
```

You can then use the name returned from the API to provision the add-on with this module by passing it to the `cluster_addons` argument:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    ...
    <add-on name>          = {}
  }
}
```

## Configuration

The EKS add-on implementation in this module is generic over all EKS supported add-ons. This means that there are no module level code changes required to support new EKS add-ons. To provision/manage add-ons via the EKS add-on API, you simply need to pass the name of the add-on as recognized by the EKS add-on API (see section above on retrieving add-on names) as the key to a map of add-on configurations:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }
}
```

The reference schema for what can be configured within each add-on is shown below:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  cluster_addons = {
    <ADD_ON_NAME> = {
      addon_version               = optional(string, <See `most_recent`>)
      configuration_values        = optional(string)
      preserve                    = optional(string, true)
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      service_account_role_arn    = optional(string)

      # Determines whether the add-on should be provisioned before the compute
      # resources. This is module specific and not part of the EKS API
      before_compute = optional(bool, false)

      # Uses the `aws_eks_addon_version` data source to look up the respective
      # default (`most_recent = false`) or latest (`most_recent = true`) version
      # for the given add-on and Kubernetes version
      most_recent = optional(bool, false)

      timeouts {
        create = optional(string)
        update = optional(string)
        delete = optional(string)
      }

      tags = optional(map(string, string))
    }
  }
}
```

The `configuration_values` will vary by add-on as well as the add-on version. You can retrieve the configuration value schema from the EKS add-on API using:

```bash
aws eks describe-addon-configuration --addon-name <VALUE> \
  --addon-version <VALUE> \
  --query 'configurationSchema' \
  --output text | jq
```

For example:

```bash
aws eks describe-addon-configuration --addon-name coredns \
  --addon-version v1.11.1-eksbuild.8 \
  --query 'configurationSchema'
  --output text | jq
```

Returns:

```json
{
  "$ref": "#/definitions/Coredns",
  "$schema": "http://json-schema.org/draft-06/schema#",
  "definitions": {
    "Coredns": {
      "additionalProperties": false,
      "properties": {
        "affinity": {
          "default": {
            "affinity": {
              "nodeAffinity": {
                "requiredDuringSchedulingIgnoredDuringExecution": {
                  "nodeSelectorTerms": [
                    {
                      "matchExpressions": [
                        {
                          "key": "kubernetes.io/os",
                          "operator": "In",
                          "values": [
                            "linux"
                          ]
                        },
                        {
                          "key": "kubernetes.io/arch",
                          "operator": "In",
                          "values": [
                            "amd64",
                            "arm64"
                          ]
                        }
                      ]
                    }
                  ]
                }
              },
              "podAntiAffinity": {
                "preferredDuringSchedulingIgnoredDuringExecution": [
                  {
                    "podAffinityTerm": {
                      "labelSelector": {
                        "matchExpressions": [
                          {
                            "key": "k8s-app",
                            "operator": "In",
                            "values": [
                              "kube-dns"
                            ]
                          }
                        ]
                      },
                      "topologyKey": "kubernetes.io/hostname"
                    },
                    "weight": 100
                  }
                ]
              }
            }
          },
          "description": "Affinity of the coredns pods",
          "type": [
            "object",
            "null"
          ]
        },
        "computeType": {
          "type": "string"
        },
        "corefile": {
          "description": "Entire corefile contents to use with installation",
          "type": "string"
        },
        "nodeSelector": {
          "additionalProperties": {
            "type": "string"
          },
          "type": "object"
        },
        "podAnnotations": {
          "properties": {},
          "title": "The podAnnotations Schema",
          "type": "object"
        },
        "podDisruptionBudget": {
          "description": "podDisruptionBudget configurations",
          "enabled": {
            "default": true,
            "description": "the option to enable managed PDB",
            "type": "boolean"
          },
          "maxUnavailable": {
            "anyOf": [
              {
                "pattern": ".*%$",
                "type": "string"
              },
              {
                "type": "integer"
              }
            ],
            "default": 1,
            "description": "minAvailable value for managed PDB, can be either string or integer; if it's string, should end with %"
          },
          "minAvailable": {
            "anyOf": [
              {
                "pattern": ".*%$",
                "type": "string"
              },
              {
                "type": "integer"
              }
            ],
            "description": "maxUnavailable value for managed PDB, can be either string or integer; if it's string, should end with %"
          },
          "type": "object"
        },
        "podLabels": {
          "properties": {},
          "title": "The podLabels Schema",
          "type": "object"
        },
        "replicaCount": {
          "type": "integer"
        },
        "resources": {
          "$ref": "#/definitions/Resources"
        },
        "tolerations": {
          "default": [
            {
              "key": "CriticalAddonsOnly",
              "operator": "Exists"
            },
            {
              "effect": "NoSchedule",
              "key": "node-role.kubernetes.io/control-plane"
            }
          ],
          "description": "Tolerations of the coredns pod",
          "items": {
            "type": "object"
          },
          "type": "array"
        },
        "topologySpreadConstraints": {
          "description": "The coredns pod topology spread constraints",
          "type": "array"
        }
      },
      "title": "Coredns",
      "type": "object"
    },
    "Limits": {
      "additionalProperties": false,
      "properties": {
        "cpu": {
          "type": "string"
        },
        "memory": {
          "type": "string"
        }
      },
      "title": "Limits",
      "type": "object"
    },
    "Resources": {
      "additionalProperties": false,
      "properties": {
        "limits": {
          "$ref": "#/definitions/Limits"
        },
        "requests": {
          "$ref": "#/definitions/Limits"
        }
      },
      "title": "Resources",
      "type": "object"
    }
  }
}
```

### Examples

Configure CoreDNS to run on EKS Fargate:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
        # Ensure that the we fully utilize the minimum amount of resources that
        # are supplied by Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required
        # Kubernetes components (kubelet, kube-proxy, and containerd). Fargate
        # rounds up to the following compute configuration that most closely
        # matches the sum of vCPU and memory requests in order to ensure pods
        # always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract
            # 256Mb from the request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract
            # 256Mb from the request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
    kube-proxy = {}
    vpc-cni    = {}
  }
}
```

EBS CSI driver requires IAM permissions to create EBS volumes and attach them to the nodes. This can be accomplished by passing an IAM role for use with IRSA:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }
}
```

Configuring the VPC CNI daemonset usually requires the configuration be in place prior to compute resources being provisioned. This can be accomplished by setting the `before_compute` flag to `true`:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Truncated for brevity
  ...

  cluster_addons = {
    coredns = {}
    eks-pod-identity-agent = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
      env = {
          AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
          ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
      })
    }
  }
}
```

## Version & Upgrades

This module uses the `aws_eks_addon_version` data source to look up the respective default (`most_recent = false`) or latest (`most_recent = true`) version for the given add-on and Kubernetes version. This ensures that you are always using a version of the add-on that is supported for the given control plane Kubernetes version. If instead you elect to specify a static version (i.e. -`addon_version = "v1.11.1-eksbuild.8"), you will need to ensure that the add-on version is compatible when upgrading the EKS control plane version.

When performing a cluster upgrade using this module and *NOT* specifying a static add-on version, this is the sequence of events that will happen during an upgrade:

1. In your module definition, change the `cluster_version` to the next incremental minor version (i.e. `1.27` -> `1.28`)
2. Run `terraform apply` to apply the changes
3. First, the EKS control plane will be upgraded to the new version (takes approximately 10 minutes to complete)
4. Next, the module will then upgrade the add-ons to either the default or latest version supported by the new control plane version using the add-on version returned by the `aws_eks_addon_version` data source.
5. In parallel, the compute resources (node groups, Fargate profiles, etc.) will be updated to align with the new control plane version provided the module defaults are utilized (i.e. - you have not configured the compute resources to a static Kubernetes version and instead that version is passed down through the module from the control plane version).
