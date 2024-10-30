resource "alicloud_ecs_key_pair" "key" {
  key_pair_name = "keypair"
  key_file      = "keypair.pem"

}
