
variable "create_vpc" {
  type        = bool
  description = "Whether to create vpc"
  default     = true
}

variable "create_igw" {
  description = "Whether to Internet gateway should be created"
  type        = bool
  default     = true
}

variable "create_ngw" {
  description = "Whether to Nat gateway should be created"
  type        = bool
  default     = false
}

variable "create_public_only" {
  type        = bool
  description = "Whether to create only public subnets"
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Whether to dns hostnames in vpc should be enabled"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC."
  default     = true
}

variable "enable_network_address_usage_metrics" {
  type        = bool
  description = "Indicates whether Network Address Usage metrics are enabled for your VPC. "
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC."
  default     = false
}

variable "instance_tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC."
  default     = "default"
}

variable "ipv4_ipam_pool_id" {
  type        = string
  description = "The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR."
  default     = null
}

variable "ipv4_netmask_length" {
  type        = string
  description = "The netmask length of the IPv4 CIDR you want to allocate to this VPC."
  default     = null
}

variable "ipv6_cidr_block" {
  type        = string
  description = "IPv6 CIDR block to request from an IPAM Pool."
  default     = null
}

variable "ipv6_ipam_pool_id" {
  type        = string
  description = " IPAM Pool ID for a IPv6 pool. Conflicts with assign_generated_ipv6_cidr_block."
  default     = null
}

variable "ipv6_netmask_length" {
  type        = string
  description = "Netmask length to request from IPAM Pool. Conflicts with ipv6_cidr_block"
  default     = null
}

variable "ipv6_cidr_block_network_border_group" {
  type        = string
  description = " By default when an IPv6 CIDR is assigned to a VPC a default ipv6_cidr_block_network_border_group will be set to the region of the VPC."
  default     = null
}

variable "multi_zone_ngw" {
  description = "Whether to Nat gateway should be created in all availability zones that are present in the specified region"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name to be used on VPC created"
  type        = string
}

variable "newbits" {
  type        = number
  description = "This is the number of additional bits with which to extend the prefix. For example, if given a prefix ending in /16 and a newbits value of 4, the resulting subnet address will have length /20"
  default     = 8
}

variable "subnet_count" {
  type        = number
  description = "subnet count for each tier. If nothing specified subnets will be created in all the availability zones that are present in the specified region"
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = null
}

variable "vpc_cidr_block" {
  description = "Cidr range for vpc"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC. Only needed if 'create_vpc' set to 'false'"
  default     = null
}

################### VPC FLOW LOGS ######################

variable "enable_flow_logs" {
  description = "The boolean flag whether to enable VPC Flow Logs in default VPCs"
  type        = bool
  default     = false
}

variable "flow_logs_destination_type" {
  description = "The type of the logging destination. Valid values: cloud-watch-logs, s3"
  type        = string
  default     = "cloud-watch-logs"
}

variable "flow_logs_retention_in_days" {
  description = "Number of days to retain logs if vpc_log_destination_type is cloud-watch-logs. CIS recommends 365 days. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely."
  type        = number
  default     = 7
}

variable "flow_logs_s3_arn" {
  description = "ARN of the S3 bucket to which VPC Flow Logs are delivered if vpc_log_destination_type is s3."
  type        = string
  default     = ""
}

variable "flow_logs_s3_key_prefix" {
  description = "The prefix used when VPC Flow Logs delivers logs to the S3 bucket."
  type        = string
  default     = "flow-logs"
}

variable "kms_key_id_log_group" {
  type        = string
  description = "The ARN of the KMS Key to use when encrypting log data."
  default     = null
}

variable "permissions_boundary_arn" {
  description = "The permissions boundary ARN for all IAM Roles, provisioned by this module"
  type        = string
  default     = null
}

variable "traffic_type" {
  type        = string
  description = "he type of traffic to capture. Valid values: ACCEPT,REJECT, ALL"
  default     = "ALL"
}

variable "max_aggregation_interval" {
  type        = number
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: 60 seconds (1 minute) or 600 seconds (10 minutes)"
  default     = 600
}

variable "destination_options" {
  type = object(
    {
      file_format                = string
      hive_compatible_partitions = bool
      per_hour_partition         = bool
    }
  )
  description = "Describes the destination options for a flow log"
  default     = null
}