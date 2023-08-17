###################### DATA SOURCE #####################

data "aws_availability_zones" "azs" {
  state = "available"
}

##################### LOCALS ###########################

locals {
  azs                  = data.aws_availability_zones.azs.names
  count                = var.subnet_count == null ? length(local.azs) : var.subnet_count
  rtb_count            = var.create_ngw && var.multi_zone_ngw && var.subnet_count == null ? length(local.azs) : var.create_ngw && var.multi_zone_ngw && var.subnet_count != null ? var.subnet_count : 0
  flow_logs_to_cw_logs = var.create_vpc && var.enable_flow_logs && (var.flow_logs_destination_type == "cloud-watch-logs")
  flow_logs_to_s3      = var.create_vpc && var.enable_flow_logs && (var.flow_logs_destination_type == "s3")
  flow_logs_s3_arn     = local.flow_logs_to_s3 ? var.flow_logs_s3_arn : null
}


####################### VPC ###########################

resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                           = var.vpc_cidr_block
  enable_dns_hostnames                 = var.enable_dns_hostnames
  instance_tenancy                     = var.instance_tenancy
  ipv4_ipam_pool_id                    = var.ipv4_ipam_pool_id
  ipv4_netmask_length                  = var.ipv4_netmask_length
  ipv6_cidr_block                      = var.ipv6_cidr_block
  ipv6_ipam_pool_id                    = var.ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.ipv6_cidr_block_network_border_group
  enable_dns_support                   = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

################ INTERNET GATEWAY ######################

resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

##################### NAT GATEWAY #######################

resource "aws_nat_gateway" "this" {
  count = var.create_ngw && var.multi_zone_ngw == false ? 1 : local.rtb_count

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = var.create_ngw && var.multi_zone_ngw == false ? "${var.name}" : "${var.name}-${local.azs[count.index]}"
    },
    var.tags
  )
}

######################## ELASTIC IP ######################

resource "aws_eip" "this" {
  count = var.create_ngw && var.multi_zone_ngw == false ? 1 : local.rtb_count

  domain = "vpc"

  tags = merge(
    {
      Name = var.create_ngw && var.multi_zone_ngw == false ? var.name : "${var.name}-${local.azs[count.index]}"
    },
    var.tags
  )
}

#################### PUBLIC TIER ########################

resource "aws_subnet" "public" {
  count = local.count

  vpc_id                  = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.newbits, count.index + 10)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.name}-public-${local.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  dynamic "route" {
    for_each = var.create_igw ? [1] : []

    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.this[0].id
    }
  }

  lifecycle {
    ignore_changes = [
      route
    ]
  }

  tags = merge(
    {
      Name = "${var.name}-public"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count = var.subnet_count == null ? length(local.azs) : var.subnet_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

################## APP TIER #########################

resource "aws_subnet" "app_private" {
  count = var.create_public_only ? 0 : local.count

  vpc_id                  = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.newbits, count.index + 20)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "${var.name}-app-private-${local.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table" "app_private" {
  count = var.create_public_only ? 0 : var.multi_zone_ngw == false ? 1 : local.rtb_count

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  dynamic "route" {
    for_each = var.create_ngw ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.multi_zone_ngw == false ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
    }
  }

  lifecycle {
    ignore_changes = [
      route
    ]
  }

  tags = merge(
    {
      Name = var.multi_zone_ngw == false ? "${var.name}-app-private" : "${var.name}-app-private-${local.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "app_private" {
  count = var.create_public_only ? 0 : local.count

  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = var.multi_zone_ngw == false ? aws_route_table.app_private[0].id : aws_route_table.app_private[count.index].id
}

##################### DB TIER #######################

resource "aws_subnet" "db_private" {
  count = var.create_public_only ? 0 : local.count

  vpc_id                  = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.newbits, count.index + 30)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "${var.name}-db-private-${local.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table" "db_private" {
  count = var.create_public_only ? 0 : var.multi_zone_ngw == false ? 1 : local.rtb_count

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  dynamic "route" {
    for_each = var.create_ngw ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.multi_zone_ngw == false ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
    }
  }

  lifecycle {
    ignore_changes = [
      route
    ]
  }

  tags = merge(
    {
      Name = var.multi_zone_ngw == false ? "${var.name}-db-private" : "${var.name}-db-private-${local.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "db_private" {
  count = var.create_public_only ? 0 : local.count

  subnet_id      = aws_subnet.db_private[count.index].id
  route_table_id = var.multi_zone_ngw == false ? aws_route_table.db_private[0].id : aws_route_table.db_private[count.index].id
}

#################### MISC TIER #######################

resource "aws_subnet" "misc_private" {
  count = var.create_public_only ? 0 : local.count

  vpc_id                  = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.newbits, count.index + 40)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "${var.name}-misc-private-${local.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table" "misc_private" {
  count = var.create_public_only ? 0 : var.multi_zone_ngw == false ? 1 : local.rtb_count

  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  dynamic "route" {
    for_each = var.create_ngw ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.multi_zone_ngw == false ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
    }
  }

  lifecycle {
    ignore_changes = [
      route
    ]
  }

  tags = merge(
    {
      Name = var.multi_zone_ngw == false ? "${var.name}-misc-private" : "${var.name}-misc-private-${local.azs[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "misc_private" {
  count = var.create_public_only ? 0 : local.count

  subnet_id      = aws_subnet.misc_private[count.index].id
  route_table_id = var.multi_zone_ngw == false ? aws_route_table.misc_private[0].id : aws_route_table.misc_private[count.index].id
}

############################### FLOW LOGS FOR VPC #######################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.enable_flow_logs && local.flow_logs_to_cw_logs ? 1 : 0

  name              = "${var.name}-flow-logs-group"
  kms_key_id        = var.kms_key_id_log_group
  retention_in_days = var.flow_logs_retention_in_days

  tags = merge(
    {
      Name = "${var.name}-flow-logs-group"
    },
    var.tags
  )
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination_type     = var.flow_logs_destination_type
  log_destination          = local.flow_logs_to_cw_logs ? aws_cloudwatch_log_group.this[0].arn : "${var.flow_logs_s3_arn}/${var.flow_logs_s3_key_prefix}"
  iam_role_arn             = local.flow_logs_to_cw_logs ? aws_iam_role.this[0].arn : null
  vpc_id                   = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id
  traffic_type             = var.traffic_type
  max_aggregation_interval = var.max_aggregation_interval

  dynamic "destination_options" {
    for_each = var.destination_options != null ? [1] : []

    content {
      file_format                = destination_options.value.file_format
      hive_compatible_partitions = destination_options.value.hive_compatible_partitions
      per_hour_partition         = destination_options.value.per_hour_partition
    }
  }

  tags = merge(
    {
      Name = "${var.name}-flow-logs"
    },
    var.tags
  )
}

########################### IAM ROLE FOR VPC FLOW LOGS #################################

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.flow_logs_to_cw_logs ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  count = local.flow_logs_to_cw_logs ? 1 : 0

  name                 = "${var.name}-vpc-flow-logs-role"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary = var.permissions_boundary_arn

  tags = merge(
    {
      Name = "${var.name}-vpc-flow-logs-role"
    },
    var.tags
  )
}

data "aws_iam_policy_document" "this" {
  count = local.flow_logs_to_cw_logs ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  count = local.flow_logs_to_cw_logs ? 1 : 0

  name   = "${var.name}-vpc-flow-logs-policy"
  role   = aws_iam_role.this[0].id
  policy = data.aws_iam_policy_document.this[0].json
}