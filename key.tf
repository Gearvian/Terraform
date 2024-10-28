# Create the Key

resource "alicloud_ecs_key_pair" "http" {
  key_pair_name = "httpkey"
  key_file      = "httpkey.pem"
}

#--------------------------------------------------------------------------------------------------------------------------