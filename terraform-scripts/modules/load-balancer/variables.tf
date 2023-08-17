
variable "certificate_arn" {
  type        = string
  description = "ACM Certificate arn for the host name"
  default     = ""
}

variable "create_listeners" {
  type        = bool
  description = "Whether the Load balancer listeners could be created"
  default     = true
}

variable "do_not_create_alb" {
  type        = bool
  description = "Whether the Load balancer could not be created"
  default     = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "whether deletion protection for load balancer could be enabled"
  default     = false
}

variable "host_names" {
  type        = list(string)
  description = "List of host name addresses"
  default     = []
}

variable "host_paths" {
  type        = list(string)
  description = "List of host paths"
  default     = []
}

variable "health_check_paths" {
  type        = list(string)
  description = "List of health check paths"
  default     = []
}

variable "http_listener_arn" {
  type        = string
  description = "Http listener arn. Is needed only if 'create_listeners' is set to 'false'"
  default     = ""
}

variable "https_listener_arn" {
  type        = string
  description = "Https listener arn. Is needed only if 'create_listeners' is set to 'false'"
  default     = ""
}

variable "load_balancer_arn" {
  type        = string
  description = "ARN of Loadbalancer. Is required if load balancer not created by this script"
  default     = null
}

variable "load_balancer_name" {
  type        = string
  description = "Name for the Load Balancer"
  default     = ""
}

variable "load_balancer_type" {
  type        = string
  description = "Type of the Load Balancer"
  default     = "application"
}

variable "name" {
  type        = list(string)
  description = "List of names for target groups"
  default     = []
}

variable "ports" {
  type        = list(number)
  description = "List of the ports for target groups"
  default     = []
}

variable "private_load_balancer" {
  type        = bool
  description = "whether the load balancer could be private"
  default     = false
}

variable "protocol" {
  type        = string
  description = "Type of the protocol for target group"
  default     = "HTTP"
}

variable "security_groups" {
  type        = list(string)
  description = "List of security groups for load balancer"
  default     = []
}

variable "ssl_policy" {
  type        = string
  description = "SSL security policy"
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of the Ids of subnets"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags for your infrastructure"
  default     = {}
}

variable "target_type" {
  type        = string
  description = "Type of the target for target group"
  default     = "ip"
}

variable "vpc_id" {
  type        = string
  description = "VPC id for target group"
  default     = ""
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  description = "If true, cross-zone load balancing of the load balancer will be enabled"
  default     = false
}

variable "enable_http2" {
  type        = bool
  description = "Indicates whether HTTP/2 is enabled in application load balancers"
  default     = true
}

variable "enable_waf_fail_open" {
  type        = bool
  description = "Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF"
  default     = false
}

variable "lb_idle_timeout" {
  type        = number
  description = "The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application."
  default     = 60
}

variable "ip_address_type" {
  type        = string
  description = "The type of IP addresses used by the subnets for your load balancer."
  default     = null
}

variable "preserve_host_header" {
  type        = bool
  description = "Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change."
  default     = false
}

variable "access_logs" {
  type = object(
    {
      bucket  = string
      prefix  = string
      enabled = bool
    }
  )
  description = "An Access Logs block."
  default     = null
}

variable "subnet_mapping" {
  type = list(
    object(
      {
        subnet_id            = string
        private_ipv4_address = string
        ipv6_address         = string
        allocation_id        = string
      }
    )
  )
  description = "A subnet mapping block"
  default     = null
}