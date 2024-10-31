#--------------------------------------------------------------------------------------------------------------------------
# Create Load Balancer  

resource "alicloud_nlb_load_balancer" "cap-nlb" {
  load_balancer_name = "nlb"
  load_balancer_type = "Network"
  address_type       = "Internet"
  address_ip_version = "Ipv4"
  vpc_id             = alicloud_vpc.capvpc.id

  zone_mappings {
    vswitch_id = alicloud_vswitch.public.id
    zone_id    = data.alicloud_zones.availability_zones.zones[0].id
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.public-b.id
    zone_id    = data.alicloud_zones.availability_zones.zones[1].id
  }
}

#--------------------------------------------------------------------------------------------------------------------------
# Create Server Group

resource "alicloud_nlb_server_group" "nlbServerGroup" {
  server_group_name        = "ServerGroup"
  server_group_type        = "Instance"  
  vpc_id                   = alicloud_vpc.capvpc.id
  scheduler                = "rr"
  protocol                 = "TCP"
  connection_drain_enabled = true
  connection_drain_timeout = 60
  address_ip_version       = "Ipv4"

  health_check {
    health_check_enabled         = true
    health_check_type            = "TCP"
    health_check_connect_port    = 0
    healthy_threshold            = 2
    unhealthy_threshold          = 2
    health_check_connect_timeout = 5
    health_check_interval        = 10
    http_check_method            = "GET"
    health_check_http_code       = ["http_2xx", "http_3xx", "http_4xx"]
  }
}

#--------------------------------------------------------------------------------------------------------------------------
# Output the DNS Name

output "outputURL" {
  value = alicloud_nlb_load_balancer.cap-nlb.dns_name
}

#--------------------------------------------------------------------------------------------------------------------------
# Attach the Servers

resource "alicloud_nlb_server_group_server_attachment" "ServerAttach" {
  count = length(alicloud_instance.caphttp)  
  server_type     = "Ecs"
  server_id       = alicloud_instance.caphttp[count.index].id
  port            = 80
  server_group_id = alicloud_nlb_server_group.nlbServerGroup.id
  weight          = 100
}

#--------------------------------------------------------------------------------------------------------------------------
# Create Listener 

resource "alicloud_nlb_listener" "nlbListener" {  
  listener_protocol      = "TCP"
  listener_port          = 80  
  load_balancer_id       = alicloud_nlb_load_balancer.cap-nlb.id
  server_group_id        = alicloud_nlb_server_group.nlbServerGroup.id
  idle_timeout           = 900  
  proxy_protocol_enabled  = false  
  cps                    = 0  
  mss                    = 0  
}
