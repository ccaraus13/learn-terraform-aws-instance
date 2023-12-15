resource "aws_alb" "petapp" {
  name = "petapp-alb"
  # Elastic Load Balancing creates a load balancer node in each zone that you specify.
  subnets = aws_subnet.public_subnets[*].id
  security_groups = [aws_security_group.inet_load_balancer.id]

  # store logs to S3
  access_logs {
    enabled = true
    bucket = "hercules-demon"
    prefix = "loadbalancer"
  }

  # if false means `Internet-Facing`: internet gateway it is required
  internal = false
}
#
###
### registering targets
###
## Notes:
## - You can configure Amazon Elastic Container Service (Amazon ECS) as a target of your Application Load Balancer
#resource "aws_lb_target_group_attachment" "register_petapp_http" {
#  target_group_arn = aws_alb_target_group.petapp.arn
#  target_id = aws_instance.petdemon.private_ip
#}

##
## Routes request to one or more registered targets
# Notes:
# - *Instance ID* type: traffic is routed to instances
#     using the primary private IP address specified in the primary network interface for the instance.
# - *IP* type:  route traffic to an instance using any private IP address from one or more network interfaces.
#     This enables multiple applications on an instance to use the same port.
#     Each network interface can have its own security group.
resource "aws_alb_target_group" "petapp" {
  name = "webapp-al-tg"
  vpc_id = aws_vpc.petcln.id
  # LB Doc: If you are registering targets by instance ID, you can use your load balancer with an Auto Scaling group
  # ECS Doc: If your service's task definition uses the awsvpc network mode (which is required for the Fargate launch type),
  #  you must choose IP addresses as the target type This is because tasks that use the awsvpc network mode are associated
  #  with an elastic network interface, not an Amazon EC2 instance.
  target_type = "ip"
  protocol = "HTTP"
  #9080
  port = var.petapp_ec2_port
  ip_address_type = "ipv4"
  slow_start = 30

  health_check {
    enabled = true
    healthy_threshold = 3
    matcher = "200,202"
    path = "/"
    protocol = "HTTP"
    port = var.petapp_ec2_port
    timeout = 5
    unhealthy_threshold = 3
  }
}

# listens on port 80, HTTP traffic
resource "aws_alb_listener" "petapp_redirect_http_to_https" {
  load_balancer_arn = aws_alb.petapp.arn
  protocol = "HTTP"
  port = "80"

  # will be invoked in case of dropped client requests
  default_action {
    type = "fixed-response"
    order = 1000
    fixed_response {
      content_type = "text/html"
      status_code = "200"
      message_body = "<b>Hmm, why I'm here(HTTP)?</b>"
    }
  }
}

# redirects HTTP to HTTPS rule
# TODO move to default_action ?
resource "aws_alb_listener_rule" "http_2_https_redirect_rule" {
  listener_arn = aws_alb_listener.petapp_redirect_http_to_https.arn
  priority = 10

  action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# listens on port 443, HTTPS traffic
resource "aws_alb_listener" "petapp_https" {
  load_balancer_arn = aws_alb.petapp.arn
  protocol = "HTTPS"
  port = "443"

  # used to terminate the connection and decrypt requests from clients before routing them to targets
  certificate_arn = var.acm_ssl_certificate_arn

  # to negotiate SSL connections between a client and the load balancer
  # security policy:  a combination of protocols and ciphers
  # The protocol establishes a secure connection between a client and a server and ensures that all data passed between the client and your load balancer is private.
  # A cipher is an encryption algorithm that uses encryption keys to create a coded message
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"


  # will be invoked in case of dropped client requests
  default_action {
    type = "fixed-response"
    order = 1000
    fixed_response {
      content_type = "text/html"
      status_code = "200"
      message_body = "<b>Hmm, why I'm here(HTTPS)?</b>"
    }
  }
}

# forward to to application ec2(target group)
resource "aws_alb_listener_rule" "forward_rule" {
  listener_arn = aws_alb_listener.petapp_https.arn
  priority = 10

  action {
    type = "forward"
    target_group_arn =  aws_alb_target_group.petapp.arn
    #    forward {
    #      target_group {
    #        arn = aws_alb_target_group.petapp.arn
    #      }
    #    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# routes traffic to load_balancer
resource "aws_route53_record" "pet_kuk88_site" {
  name    = var.petapp_main_domain
  type    = "A"
  zone_id = var.route53_hosted_zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_alb.petapp.dns_name
    zone_id                = aws_alb.petapp.zone_id
  }

}

resource "aws_route53_health_check" "domain_health_check" {
  fqdn = var.petapp_main_domain
  type = "HTTPS"
  port = 443
  request_interval = 30
  resource_path = "/"
  failure_threshold = 3

  tags = {
    "Name" = format("%s https check", var.petapp_main_domain)
  }
}
