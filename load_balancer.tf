#resource "aws_alb" "petapp" {
#  name = "petapp-alb"
#  subnets = aws_subnet.public_subnets[*].id
#  security_groups = [aws_security_group.web_server.id]
#}
#
#resource "aws_lb_target_group_attachment" "register_petapp_http" {
#  target_group_arn = aws_alb_target_group.petapp.arn
#  target_id = aws_instance.petdemon.private_ip
#  port = 9080
#}
#
###TODO do we need this for SSM?
##resource "aws_lb_target_group_attachment" "register_petapp_ssh" {
##  target_group_arn = aws_alb_target_group.petapp_ssh.arn
##  target_id = aws_instance.petdemon.id
##  port = 22
##}
#
#resource "aws_alb_target_group" "petapp" {
#  name = "webapp-al-tg"
#  vpc_id = aws_vpc.petcln.id
#  # LB Doc: If you are registering targets by instance ID, you can use your load balancer with an Auto Scaling group
#  # ECS Doc: If your service's task definition uses the awsvpc network mode (which is required for the Fargate launch type),
#  #  you must choose IP addresses as the target type This is because tasks that use the awsvpc network mode are associated
#  #  with an elastic network interface, not an Amazon EC2 instance.
#  target_type = "ip" #TODO IP or instanceID?
#  protocol = "HTTP"
#  port = 9080 #???
#  ip_address_type = "ipv4"
#}
#
###TODO do we need this for SSM?
##resource "aws_alb_target_group" "petapp_ssh" {
##  name = "webapp-al-tg"
##  vpc_id = aws_vpc.petcln.id
##  target_type = "ip"
##  protocol = "TCP" #HTTP or HTTPS only
##  port = 22 #???
##  ip_address_type = "ipv4"
##}
#
##TODO HTTPS
#resource "aws_alb_listener" "petapp_http" {
#  load_balancer_arn = aws_alb.petapp.arn
#  protocol = "HTTP"
#  port = "80"
#  default_action {
#    type = "forward"
#    target_group_arn = aws_alb_target_group.petapp.arn
#  }
#}
#
###TODO do we need this for SSM?
##resource "aws_alb_listener" "petapp_ssh" {
##  load_balancer_arn = aws_alb.petapp.arn
##  protocol = "TCP"
##  port = "22"
##  default_action {
##    type = "forward"
##    target_group_arn = aws_alb_target_group.petapp_ssh.arn #TODO where?
##  }
##}
#
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
