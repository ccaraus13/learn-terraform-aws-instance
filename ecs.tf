resource "aws_ecs_cluster" "hercules_cluster" {
  name = "hercules"

}

resource "aws_ecs_cluster_capacity_providers" "hercules" {
  cluster_name = aws_ecs_cluster.hercules_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.pet_cas.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.pet_cas.name
    base = 1
    weight = 100
  }
}

# manage the scaling of infrastructure for tasks in a cluster
resource "aws_ecs_capacity_provider" "pet_cas" {
  name = "pet_capacity_provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.pet_scaler.arn

    managed_scaling {
      instance_warmup_period = 200
      # min nr of EC2 instances that will scale out at one time
      minimum_scaling_step_size = 1
      # max nr of EC2 instances that will scale out at one time
      maximum_scaling_step_size = 1

      status = "ENABLED"

      # ??  The default value of 100 percent results in the Amazon EC2 instances in your Auto Scaling group being completely used.
      # CapacityProviderReservation = ( M / N ) * 100 (where M - nr of needed instances; N - nr of running instances)
      # used to decide if scale in or out should be done, so that the metric `CapacityProviderReservation` have the provided value `target_capacity`
      target_capacity = 100
    }

    managed_termination_protection = "ENABLED"
  }
}

resource "aws_autoscaling_group" "pet_scaler" {
  name = "pet-scaling"
#  warm_pool {}
  max_size = 3
  min_size = 1
#  Number of Amazon EC2 instances that should be running in the group
  desired_capacity = 1 # may be 0, since it is managed by capacity provider in this case
  vpc_zone_identifier = aws_subnet.private_subnets[*].id

  launch_template {
    id = aws_launch_template.app_container.id
    version = "$Latest"
  }
  protect_from_scale_in = true #if false, aws_ecs_capacity_provider will not be able to perform scale-in

}

resource "aws_ecs_task_definition" "petapp" {
  family = "petapp"

  container_definitions = templatefile("task-definitions/service.json.tftpl", {
    container_name = var.petapp_task_container_name,
    docker_image_repo =  var.petapp_docker_image_repo,
    docker_image_tag = var.petapp_docker_image_tag,
    host_port = var.petapp_ec2_port,
    aws_region = var.region,
    # may be auto-created by enabling option: `"awslogs-create-group": "true"`,
    # requires `logs:CreateLogStream` and `logs:PutLogEvents` IAM policies defined in ecsINstanceRole(added to EC2) or to `execution_role_arn`
    log_group = "ssm-4-hercules"
  })

  requires_compatibilities = ["EC2"]
  network_mode = "awsvpc"

  # optional for EC2 instance, if cluster doesn't have containers with specified limits, task will fail
  #  cpu = 1024 #TODO 1 vCPU?
  #  memory = 1024 #TODO in GB ?
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
}

resource "aws_ecs_service" "petapp" {
  name = "petapp_service"
  task_definition = aws_ecs_task_definition.petapp.arn #ARN or "family:revision"
  cluster = aws_ecs_cluster.hercules_cluster.arn
  scheduling_strategy = "REPLICA"
  desired_count = 1
  enable_ecs_managed_tags = true

  # if capacity_provider_strategy and launch_type are not defined, the default_capacity_provider_strategy is used
  #  capacity_provider_strategy {
  #    capacity_provider = ""
  #  }

  # optionally specify task placement strategies and constraints to customize task placement decisions
  # TODO binpack & distinct instance... Will this resulting in ignoring binpack if running same task?
#  placement_constraints {
#    type = "distinctInstance"
#  }

#  Amazon ECS uses placement strategy and placement constraints with the existing capacity at the current time.
#  A placement strategy can spread tasks across Availability Zones or Amazon ECS instances.
#  This eventually spreads all the tasks and all the instances so that each running task
#  launches on its own dedicated instance. To prevent this, don't use the `spread` strategy
#  together with the `binpack` strategy.
  #TODO try it
#  ordered_placement_strategy {
#    type = "binpack"
#    field = "memory"
#  }
  # default is spread & attribute:ecs.availability-zone if no one is specified
  ordered_placement_strategy {
    type = "spread"
    field = "attribute:ecs.availability-zone"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets = aws_subnet.private_subnets[*].id
    security_groups = [aws_security_group.web_server.id]
  }

  load_balancer {
    container_name = var.petapp_task_container_name
    container_port = var.petapp_ec2_port #9080
    target_group_arn = aws_alb_target_group.petapp.arn
  }

  deployment_minimum_healthy_percent = 50
}