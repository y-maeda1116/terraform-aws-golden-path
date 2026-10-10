# ECS Fargate: プライベートサブネット・非特権コンテナ・ヘルスチェック連動
resource "aws_ecs_cluster" "this" {
  name = var.name_prefix

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name_prefix}-ecs-tasks"
  description = "ECS tasks: ingress from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App port from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all egress (app outbound via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #trivy:ignore:AVD-AWS-0104 NAT egress for app outbound (calls to external endpoints via NAT gateway)
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.name_prefix}-app"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_key_arn
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name_prefix}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "${var.name_prefix}-app"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      # 非特権・読み取り専用ルート FS（標準化レイヤ）
      privileged             = false
      readonlyRootFilesystem = true

      linuxParameters = {
        capabilities = {
          drop = ["ALL"]
        }
        # readonlyRootFilesystem のため、書き込みが必要なパスは tmpfs で提供
        tmpfs = [
          { containerPath = "/tmp", size = 64 },
          { containerPath = "/var/cache/nginx", size = 64 },
          { containerPath = "/var/run", size = 16 },
        ]
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${var.name_prefix}-app"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${var.name_prefix}-app"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = 30
}
