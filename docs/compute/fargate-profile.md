# Fargate Profile

The Fargate Profile implementation is rather straightforward; it simply wraps the underlying [`eks_fargate_profile` resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile)

## Example

```terraform
{% include  "../../examples/fargate-profile/eks.tf" %}
```
