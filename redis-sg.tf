# Create redis Security Group
resource "alicloud_security_group" "redis" {
  name        = "redis"
  description = "redis security group"
  vpc_id      = alicloud_vpc.vpc.id
}

#--------------------------------------------------------------------------------------------------------------------------
# Create redis Security Group Rule to allow redis to accses redis using SSH and HTTP

resource "alicloud_security_group_rule" "allow_bastion_to_ssh" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.redis.id
  source_security_group_id = alicloud_security_group.bastion.id
}

#--------------------------------------------------------------------------------------------------------------------------
# Create redis Security Group Rule to allow web to accses redis using port 6379

resource "alicloud_security_group_rule" "allow_web_to_redis" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "6379/6379"
  priority                 = 1
  security_group_id        = alicloud_security_group.redis.id
  source_security_group_id = alicloud_security_group.http.id
}

#--------------------------------------------------------------------------------------------------------------------------