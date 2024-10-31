resource "alicloud_instance" "capredis" {
  availability_zone = data.alicloud_zones.availability_zones.zones.0.id
  security_groups   = [alicloud_security_group.redis.id]

  host_name = "redis"

  # series III
  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "redis"
  vswitch_id                 = alicloud_vswitch.private.id
  internet_max_bandwidth_out = 0
  internet_charge_type       = "PayByTraffic"
  instance_charge_type       = "PostPaid"
  key_name                   = alicloud_ecs_key_pair.capstone-key.key_pair_name

  user_data = base64encode(file("redis-setup.sh"))

}

output "redis_server_private_ip" {
  value = alicloud_instance.capredis.private_ip
}
