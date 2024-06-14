# Storage

## Amazon Linux 2

### Root EBS Volume

```sh
aws ec2 describe-images --image-ids $(aws ssm get-parameter \
    --name /aws/service/eks/optimized-ami/1.30/amazon-linux-2/recommended/image_id \
    --region us-east-1 --query "Parameter.Value" --output text) \
  --region us-east-1 --query "Images[0].BlockDeviceMappings[*].DeviceName"
```

### [Instance Store Volume(s)](https://awslabs.github.io/amazon-eks-ami/usage/al2/#ephemeral-storage)

## Amazon Linux 2023

### Root EBS Volume

```sh
aws ec2 describe-images --image-ids $(aws ssm get-parameter \
    --name /aws/service/eks/optimized-ami/1.30/amazon-linux-2023/x86_64/standard/recommended/image_id \
    --region us-east-1 --query "Parameter.Value" --output text) \
  --region us-east-1 --query "Images[0].BlockDeviceMappings[*].DeviceName"
```

### [Instance Store Volume(s)](https://awslabs.github.io/amazon-eks-ami/nodeadm/doc/api/#localstoragestrategy)

## Bottlerocket

```sh
aws ec2 describe-images --image-ids $(aws ssm get-parameter \
    --name /aws/service/bottlerocket/aws-k8s-1.30/x86_64/latest/image_id \
    --region us-east-1 --query "Parameter.Value" --output text) \
  --region us-east-1 --query "Images[0].BlockDeviceMappings[*].DeviceName"
```

### EBS Volume(s)

### Instance Store Volume(s)

!!! info
    Please follow [bottlerocket/issues/3060](https://github.com/bottlerocket-os/bottlerocket/issues/3060) for Bottlerocket support of instance store volumes.
