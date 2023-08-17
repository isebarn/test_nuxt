############## DATA SOURCE ##################

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

locals {
  count       = length(var.name)
  account_id  = data.aws_caller_identity.this.account_id
  region      = data.aws_region.this.name
  http_action = var.certificate_arn != ""
}

##################################### LOAD BALANCER #####################################

resource "aws_lb" "this" {
  count = var.do_not_create_alb ? 0 : 1

  name                             = var.load_balancer_name
  internal                         = var.private_load_balancer
  load_balancer_type               = var.load_balancer_type
  security_groups                  = var.security_groups
  subnets                          = var.subnet_ids
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                     = var.enable_http2
  enable_waf_fail_open             = var.enable_waf_fail_open
  idle_timeout                     = var.lb_idle_timeout
  ip_address_type                  = var.ip_address_type
  preserve_host_header             = var.preserve_host_header

  dynamic "access_logs" {
    for_each = var.access_logs != null ? [1] : []

    content {
      bucket  = var.access_logs.bucket_id
      prefix  = lookup(access_logs.value, "prefix", null)
      enabled = lookup(access_logs.value, "enabled", null)
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping != null ? var.subnet_mapping : []

    content {
      subnet_id            = var.subnet_mapping.subnet_id
      private_ipv4_address = lookup(subnet_mapping.value, "private_ipv4_address", null)
      ipv6_address         = lookup(subnet_mapping.value, "ipv6_address", null)
      allocation_id        = lookup(subnet_mapping.value, "allocation_id", null)
    }
  }

  tags = merge({
    "Name" = var.load_balancer_name
    },
    var.tags
  )

}

######################## LISTENER GROUP FOR HTTP ####################################

resource "aws_lb_listener" "http" {
  count = var.create_listeners ? 1 : 0

  load_balancer_arn = var.do_not_create_alb == false ? aws_lb.this[0].arn : var.load_balancer_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = local.http_action ? "redirect" : "forward"
    target_group_arn = local.http_action ? null : aws_lb_target_group.this[0].arn

    dynamic "redirect" {
      for_each = local.http_action ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener_rule" "http" {
  count = var.create_listeners && length(var.host_names) > 0 ? 1 : 0

  priority     = 100
  listener_arn = var.create_listeners ? aws_lb_listener.http[0].arn : var.http_listener_arn

  condition {
    host_header {
      values = [var.host_names[0]]
    }
  }

  action {
    type             = local.http_action ? "redirect" : "forward"
    target_group_arn = local.http_action ? null : aws_lb_target_group.this[0].arn

    dynamic "redirect" {
      for_each = local.http_action ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

################################## LISTENER CREATION HTTPS #####################################################

resource "aws_lb_listener" "https" {
  count = var.create_listeners && var.do_not_create_alb == false && var.certificate_arn != "" ? 1 : 0

  load_balancer_arn = var.do_not_create_alb == false ? aws_lb.this[0].arn : var.load_balancer_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}


resource "aws_lb_listener_rule" "https" {
  count = var.create_listeners && var.do_not_create_alb == false && var.certificate_arn != "" ? 1 : 0

  priority     = 100
  listener_arn = var.create_listeners ? aws_lb_listener.https[0].arn : var.https_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    host_header {
      values = [var.host_names[0]]
    }
  }
}

####################### TARGET GROUP #############################

resource "aws_lb_target_group" "this" {
  count       = local.count
  name        = var.name[count.index]
  port        = 80
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = var.name[count.index]
    },
    var.tags
  )

  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-410"
    timeout             = "5"
    path                = length(var.health_check_paths) > 1 ? var.health_check_paths[count.index] : var.health_check_paths[0]
    unhealthy_threshold = "3"
    port                = length(var.ports) > 1 ? var.ports[count.index] : var.ports[0]
  }
}
