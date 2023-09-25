resource "aws_alb" "petapp" {
  name = "petapp-alb"
  # Elastic Load Balancing creates a load balancer node in each zone that you specify.
  subnets = aws_subnet.public_subnets[*].id
  security_groups = [aws_security_group.inet_load_balancer.id]

  # TODO fix S3 policy
  access_logs {
    enabled = true
    bucket = "hercules-demon"
    prefix = "loadbalancer"
  }

  # if false means `Internet-Facing`: internet gateway it is required
  internal = false
}

##
## registering targets
##
# Notes:
# - You can configure Amazon Elastic Container Service (Amazon ECS) as a target of your Application Load Balancer
resource "aws_lb_target_group_attachment" "register_petapp_http" {
  target_group_arn = aws_alb_target_group.petapp.arn
  target_id = aws_instance.petdemon.private_ip
}

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
  port = 9080
  ip_address_type = "ipv4"
  slow_start = 30

  health_check {
    enabled = true
    healthy_threshold = 3
    matcher = "200,202"
    path = "/"
    protocol = "HTTP"
    port = 9080
    timeout = 5
    unhealthy_threshold = 3
  }
}

#TODO HTTPS
resource "aws_alb_listener" "petapp_http" {
  load_balancer_arn = aws_alb.petapp.arn
  protocol = "HTTP"
  port = "80"

  # will be invoked inc ase of dropped client requests
  default_action {
    type = "fixed-response"
    order = 1000
    fixed_response {
      content_type = "text/html"
      status_code = "200"
      message_body = "<b>Hmm, why I'm here?</b>"
    }
  }
}

# forward to to application ec2(target group)
resource "aws_alb_listener_rule" "forward_rule" {
  listener_arn = aws_alb_listener.petapp_http.arn
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

##resource "aws_alb_listener" "petapp_https" {
##  load_balancer_arn = aws_alb.petapp.arn
##  protocol = "HTTPS"
##  port = "443"
##  certificate_arn = "" #TODO
##  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
##  default_action {
##    type = "forward"
##    target_group_arn = aws_alb_target_group.petapp.arn
##  }
##}
##
##resource "aws_alb_listener" "petapp_http" {
##  load_balancer_arn = aws_alb.petapp.arn
##  protocol = "HTTP"
##  port = "80"
##  default_action {
##    type = "redirect"
##
##    redirect {
##      status_code = "HTTP_301"
##      port = "443"
##      protocol = "HTTPS"
##    }
##  }
##}
