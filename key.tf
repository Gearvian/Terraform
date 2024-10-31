resource "alicloud_ecs_key_pair" "capstone-key" {
  key_pair_name = "capstone-key"
  key_file      = "capstone-key.pem"
}
