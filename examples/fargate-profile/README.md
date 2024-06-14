# EKS Fargate Profile Example

Configuration in this directory creates Amazon EKS clusters with EKS Fargate Profile.

## Usage

To provision the provided configurations you need to execute:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.
