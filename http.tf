resource "alicloud_instance" "http" {
  count             = 2
  availability_zone = data.alicloud_zones.default.zones.0.id
  security_groups   = [alicloud_security_group.http_sg.id]

  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "http-${count.index}"
  vswitch_id                 = alicloud_vswitch.private.id
  internet_max_bandwidth_out = 0
  instance_charge_type       = "PostPaid"
  key_name                   = alicloud_ecs_key_pair.key.key_pair_name
  user_data                  = base64encode(templatefile("http_setup.tpl", { 
    redis_host = alicloud_instance.redis.private_ip, 
  mysql_host = alicloud_instance.mysql.private_ip }))
}

output "http_private_ips" {
  value = alicloud_instance.http.*.private_ip
}

resource "alicloud_security_group" "http_sg" {
  name        = "http_sg"
  description = "http_sg"
  vpc_id      = alicloud_vpc.vpc.id
}
resource "alicloud_security_group_rule" "http_sg_allow_ssh" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.http_sg.id
  source_security_group_id = alicloud_security_group.bastion_sg.id
}


resource "alicloud_security_group_rule" "http_sg_allow_http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "5000/5000"
  priority          = 1
  security_group_id = alicloud_security_group.http_sg.id
  # source_security_group_id = alicloud_security_group.http_sg.id  
  cidr_ip = "0.0.0.0/0"
}


