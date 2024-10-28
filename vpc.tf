# Creating the VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = "lab-1"
  cidr_block = "10.0.0.0/8"
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating the Zone

data "alicloud_zones" "availability_zones" {
  available_resource_creation = "VSwitch"
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating the first public VSwitch

resource "alicloud_vswitch" "public" {
  vswitch_name = "public-a"  # Unique name
  cidr_block   = "10.0.1.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones[0].id
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating the 2nd public VSwitch

resource "alicloud_vswitch" "public_b" {
  vswitch_name = "public-b"  # Unique name
  cidr_block   = "10.0.3.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones[1].id
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating the private VSwitch

resource "alicloud_vswitch" "private" {
  vswitch_name = "private"  # Unique name
  cidr_block   = "10.0.2.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones[0].id
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating the NAT Gateway in the public VSwitch

resource "alicloud_nat_gateway" "default" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "nat-gateway"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.public.id
  nat_type         = "Enhanced"
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating EIP for the NAT Gateway

resource "alicloud_eip_address" "nat" {
  description          = "NAT EIP"
  address_name         = "nat-eip"
  netmode              = "public"
  bandwidth            = 100  # Use integer, not string
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}

#--------------------------------------------------------------------------------------------------------------------------
# Associating the NAT Gateway with EIP

resource "alicloud_eip_association" "nat" {
  allocation_id = alicloud_eip_address.nat.id
  instance_id   = alicloud_nat_gateway.default.id
  instance_type = "Nat"
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating SNAT

resource "alicloud_snat_entry" "http_private" {
  snat_table_id     = alicloud_nat_gateway.default.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private.id
  snat_ip           = alicloud_eip_address.nat.ip_address
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating a route table for the private VSwitch

resource "alicloud_route_table" "private" {
  description      = "Private Route Table"
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = "private"
  associate_type   = "VSwitch"
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating a NAT Entry 

resource "alicloud_route_entry" "nat" {
  route_table_id        = alicloud_route_table.private.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.default.id
}

#--------------------------------------------------------------------------------------------------------------------------
# Creating route table attachment 

resource "alicloud_route_table_attachment" "private" {
  vswitch_id     = alicloud_vswitch.private.id
  route_table_id = alicloud_route_table.private.id
}