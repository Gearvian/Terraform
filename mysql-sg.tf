
resource "alicloud_security_group" "mysql" {
  name        = "mysql"
  description = "mysql security group"
  vpc_id      = alicloud_vpc.capvpc.id
}


resource "alicloud_security_group_rule" "allow_bastion_sql" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "3306/3306"
  priority                 = 1
  security_group_id        = alicloud_security_group.mysql.id
  source_security_group_id = alicloud_security_group.http.id
}

resource "alicloud_security_group_rule" "allow_ssh_to_sql" {
  type                     = "ingress"
  ip_protocol              = "tcp"
  policy                   = "accept"
  port_range               = "22/22"
  priority                 = 1
  security_group_id        = alicloud_security_group.mysql.id
  source_security_group_id = alicloud_security_group.bastion.id
}
