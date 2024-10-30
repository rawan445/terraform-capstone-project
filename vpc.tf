resource "alicloud_vpc" "vpc" {
  description = "vpc"
  cidr_block  = "10.0.0.0/8"
  vpc_name    = "capstone-vpc"
}
data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}

resource "alicloud_vswitch" "public" {
  vswitch_name = "public"
  cidr_block   = "10.0.1.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.default.zones.0.id
}
resource "alicloud_vswitch" "public-b" {
  vswitch_name = "public-b"
  cidr_block   = "10.0.3.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.default.zones.1.id
}

resource "alicloud_vswitch" "private" {
  vswitch_name = "private"
  cidr_block   = "10.0.2.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.default.zones.0.id
}


resource "alicloud_nat_gateway" "nat" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "nat"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.public.id
  nat_type         = "Enhanced"
}

resource "alicloud_eip_address" "nat" {
  description          = "Nat IP"
  address_name         = "nat"
  netmode              = "public"
  bandwidth            = "100"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}


resource "alicloud_eip_association" "nat" {
  allocation_id = alicloud_eip_address.nat.id
  instance_id   = alicloud_nat_gateway.nat.id
  instance_type = "Nat"
}

resource "alicloud_snat_entry" "private-ssh" {
  snat_table_id     = alicloud_nat_gateway.nat.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private.id
  snat_ip           = alicloud_eip_address.nat.ip_address
}

resource "alicloud_route_table" "private_rt" {
  description      = "private_rt"
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = "private_rt"
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "private" {
  route_table_id        = alicloud_route_table.private_rt.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.nat.id

  # depends_on = [
  #   alicloud_nat_gateway.nat,
  #   alicloud_snat_entry.private-ssh,
  #   alicloud_eip_association.nat
  # ]
}

resource "alicloud_route_table_attachment" "link_rt_private" {
  vswitch_id     = alicloud_vswitch.private.id
  route_table_id = alicloud_route_table.private_rt.id
}
