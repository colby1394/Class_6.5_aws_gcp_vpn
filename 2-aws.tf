

locals {
  default_num_ha_vpn_interfaces = 2
}

# Create a VPC for testing
# https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/ec2_vpc
resource "awscc_ec2_vpc" "example" {
  cidr_block = "10.190.0.0/16"

  tags = [{
    key   = "Name"
    value = "TGW-Attachment-Example"
  }]
}

# Create subnets for the TGW attachment
# https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/ec2_subnet
resource "awscc_ec2_subnet" "example" {
  vpc_id     = awscc_ec2_vpc.example.id
  cidr_block = "10.190.1.0/24"

  tags = [{
    key   = "Name"
    value = "TGW-Attachment-Subnet"
  }]
}

# Create a VPN Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway
resource "aws_customer_gateway" "gwy" {
  count = local.default_num_ha_vpn_interfaces

  device_name = "${var.prefix}-gwy-${count.index}"
  bgp_asn     = var.gcp_router_asn
  type        = "ipsec.1"
  ip_address  = google_compute_ha_vpn_gateway.gwy.vpn_interfaces[count.index]["ip_address"]
}

# Create a Transit Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway
resource "aws_ec2_transit_gateway" "tgw" {
  amazon_side_asn                 = var.aws_router_asn
  description                     = "EC2 transit gateway"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  vpn_ecmp_support                = "enable"
  dns_support                     = "enable"

  tags = {
    Name = "${var.prefix}-tgw"
  }
}

# Create a transit gateway attachment
# This is a workaround for the issue with aws_ec2_transit_gateway_attachment
# https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/ec2_transit_gateway_attachment
resource "awscc_ec2_transit_gateway_attachment" "tgw_attachment" {
  subnet_ids         = [awscc_ec2_subnet.example.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = awscc_ec2_vpc.example.id

  tags = [
    {
      key   = "Name"
      value = "${var.prefix}-tgw-attachment"
    }
  ]
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection
resource "aws_vpn_connection" "vpn_conn" {
  count = var.num_tunnels / 2

  customer_gateway_id   = aws_customer_gateway.gwy[count.index % 2].id
  type                  = "ipsec.1"
  transit_gateway_id    = aws_ec2_transit_gateway.tgw.id
  tunnel1_preshared_key = var.shared_secret
  tunnel2_preshared_key = var.shared_secret2
  tunnel1_ike_versions = ["ikev2"]
  tunnel2_ike_versions = ["ikev2"]
  tunnel1_inside_cidr  = "169.254.1${count.index * 2}.0/30"
  tunnel2_inside_cidr  = "169.254.2${count.index * 2 + 1}.0/30"
  tunnel1_phase1_dh_group_numbers  = ["16"]
  tunnel2_phase1_dh_group_numbers  = ["16"]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms = ["SHA2-256"]
  tunnel2_phase1_integrity_algorithms = ["SHA2-256"]

  tags = {
    Name = "${var.prefix}-vpn-connn"
  }
}