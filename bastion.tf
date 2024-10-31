resource "alicloud_instance" "capbastion" {
  availability_zone = data.alicloud_zones.availability_zones.zones.0.id
  security_groups   = [alicloud_security_group.bastion.id]

  # series III
  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "bastion"
  vswitch_id                 = alicloud_vswitch.public.id
  internet_max_bandwidth_out = 100
  instance_charge_type       = "PostPaid"
  internet_charge_type       = "PayByTraffic"
  key_name                   = alicloud_ecs_key_pair.capstone-key.key_pair_name

}

output "bastion_server_public_ip" {
  value = alicloud_instance.capbastion.public_ip
}