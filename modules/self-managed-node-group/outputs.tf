################################################################################
# Launch template
################################################################################

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = try(aws_launch_template.this[0].id, "")
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = try(aws_launch_template.this[0].arn, "")
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = try(aws_launch_template.this[0].latest_version, "")
}

################################################################################
# Node Group
################################################################################

output "node_group_arn" {
  description = "The ARN for this node group"
  value       = try(aws_autoscaling_group.this[0].arn, "")
}

output "node_group_id" {
  description = "The node group id"
  value       = try(aws_node_group.this[0].id, "")
}

output "node_group_name" {
  description = "The node group name"
  value       = try(aws_autoscaling_group.this[0].name, "")
}

output "node_group_min_size" {
  description = "The minimum size of the node group"
  value       = try(aws_autoscaling_group.this[0].min_size, "")
}

output "node_group_max_size" {
  description = "The maximum size of the node group"
  value       = try(aws_autoscaling_group.this[0].max_size, "")
}

output "node_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = try(aws_autoscaling_group.this[0].desired_capacity, "")
}

output "node_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = try(aws_autoscaling_group.this[0].default_cooldown, "")
}

output "node_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = try(aws_autoscaling_group.this[0].health_check_grace_period, "")
}

output "node_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = try(aws_autoscaling_group.this[0].health_check_type, "")
}

output "node_group_availability_zones" {
  description = "The availability zones of the node group"
  value       = try(aws_autoscaling_group.this[0].availability_zones, "")
}

output "node_group_vpc_zone_identifier" {
  description = "The VPC zone identifier"
  value       = try(aws_autoscaling_group.this[0].vpc_zone_identifier, "")
}

################################################################################
# Node group schedule
################################################################################

output "node_schedule_arns" {
  description = "ARNs of autoscaling group schedules"
  value       = { for k, v in aws_autoscaling_schedule.this : k => v.arn }
}


################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, "")
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, "")
}

################################################################################
# IAM Role
################################################################################

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = try(aws_iam_role.this[0].name, "")
}

output "iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.this[0].arn, "")
}

output "iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = try(aws_iam_role.this[0].unique_id, "")
}

################################################################################
# IAM Instance Profile
################################################################################

output "iam_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, "")
}

output "iam_instance_profile_id" {
  description = "Instance profile's ID"
  value       = try(aws_iam_instance_profile.this[0].id, "")
}

output "iam_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = try(aws_iam_instance_profile.this[0].unique_id, "")
}
