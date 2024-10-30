
resource "alicloud_instance" "mysql" {
  availability_zone = data.alicloud_zones.default.zones.0.id
  security_groups   = [alicloud_security_group.mysql_sg.id]


  instance_name              = "mysql"
  instance_type              = "ecs.g6.large"
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_charge_type       = "PostPaid"
  system_disk_category       = "cloud_essd"
  vswitch_id                 = alicloud_vswitch.private.id
  key_name                   = alicloud_ecs_key_pair.key.key_pair_name
  internet_max_bandwidth_out = 0
  internet_charge_type       = "PayByTraffic"
  user_data = base64encode(templatefile("mysql_setup.tpl", {
    mysql_root_password = var.mysql_root_password
    mysql_database      = var.mysql_database
  }))

}
output "mysql_private_ip" {
  value = alicloud_instance.mysql.private_ip
}

resource "alicloud_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "mysql_sg"
  vpc_id      = alicloud_vpc.vpc.id
}
resource "alicloud_security_group_rule" "allow_http_mysql_ssh" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.mysql_sg.id
  source_security_group_id = alicloud_security_group.bastion_sg.id
}
resource "alicloud_security_group_rule" "mysql_sg_allow_ssh" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.mysql_sg.id
  source_security_group_id = alicloud_security_group.http_sg.id
}

resource "alicloud_security_group_rule" "mysql_sg_allow_mysql" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "3306/3306"
  priority                 = 1
  security_group_id        = alicloud_security_group.mysql_sg.id
  source_security_group_id = alicloud_security_group.http_sg.id
}
