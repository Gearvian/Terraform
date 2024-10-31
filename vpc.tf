resource "alicloud_vpc" "capvpc" {
  vpc_name   = "lab-1"
  cidr_block = "10.0.0.0/8"
}

data "alicloud_zones" "availability_zones" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

resource "alicloud_vswitch" "public" {
  vswitch_name = "public"
  cidr_block   = "10.0.1.0/24"
  vpc_id       = alicloud_vpc.capvpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones.0.id
}

resource "alicloud_vswitch" "public-b" {
  vswitch_name = "public"
  cidr_block   = "10.0.3.0/24"
  vpc_id       = alicloud_vpc.capvpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones.1.id
}

resource "alicloud_vswitch" "private" {
  vswitch_name = "private"
  cidr_block   = "10.0.2.0/24"
  vpc_id       = alicloud_vpc.capvpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones.0.id
}

resource "alicloud_nat_gateway" "capnatgateway" {
  vpc_id           = alicloud_vpc.capvpc.id
  nat_gateway_name = "http"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.public.id
  nat_type         = "Enhanced"
}

resource "alicloud_eip_address" "capnateip" {
  description          = "nat"
  address_name         = "nat"
  netmode              = "public"
  bandwidth            = "100"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "nateip" {
  allocation_id = alicloud_eip_address.capnateip.id
  instance_id   = alicloud_nat_gateway.capnatgateway.id
  instance_type = "Nat"
}
resource "alicloud_snat_entry" "private_snat" {
  snat_table_id     = alicloud_nat_gateway.capnatgateway.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private.id
  snat_ip           = alicloud_eip_address.capnateip.ip_address
}

resource "alicloud_route_table" "private" {
  description      = "Private"
  vpc_id           = alicloud_vpc.capvpc.id
  route_table_name = "private"
  associate_type   = "VSwitch"
}

resource "alicloud_route_table_attachment" "private" {
  vswitch_id     = alicloud_vswitch.private.id
  route_table_id = alicloud_route_table.private.id
}

resource "alicloud_route_entry" "natentry" {
  route_table_id        = alicloud_route_table.private.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.capnatgateway.id
}

