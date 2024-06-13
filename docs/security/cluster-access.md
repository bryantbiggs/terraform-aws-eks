# Cluster Access

## Access Entry

When enabling `authentication_mode = "API_AND_CONFIG_MAP"`, EKS will automatically create an access entry for the IAM role(s) used by managed node group(s) and Fargate profile(s). There are no additional actions required by users. For self-managed node groups and the Karpenter sub-module, this project automatically adds the access entry on behalf of users so there are no additional actions required by users.

On clusters that were created prior to CAM support, there will be an existing access entry for the cluster creator. This was previously not visible when using `aws-auth` ConfigMap, but will become visible when access entry is enabled.

## aws-auth ConfigMap

TODO

## Bootstrap Cluster Creator

Setting the `bootstrap_cluster_creator_admin_permissions` is a one time operation when the cluster is created; it cannot be modified later through the EKS API. In this project we are hardcoding this to `false`. If users wish to achieve the same functionality, we will do that through an access entry which can be enabled or disabled at any time of their choosing using the variable `enable_cluster_creator_admin_permissions`
