# ecs.tf

resource "aws_ecs_cluster" "main" {
    name = "cb-cluster"
}


resource "aws_ecs_task_definition" "app" {
    family                   = "cb-app-task"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = var.fargate_cpu
    memory                   = var.fargate_memory
    container_definitions    = jsonencode([
  {
    "name": "cb-app",
    "image": var.app_image,
    "cpu": var.fargate_cpu,
    "memory": var.fargate_memory,
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/cb-app",
          "awslogs-region": var.aws_region,
          "awslogs-stream-prefix": "ecs"
        }
    },
    "environment" = [
        {
          name  = "XDM_REPOSITORY_DRIVER"
          value = "org.postgresql.Driver"
        },
                {
          name  = "XDM_REPOSITORY_URL"
          value = "jdbc:postgresql://${aws_rds_cluster_instance.cluster_instances.endpoint}:5432/${aws_rds_cluster.aurora_postgres.database_name}"
        },
        {
          name  = "XDM_REPOSITORY_USERNAME"
          value = "semarchy_repository"
        },
        {
          name  = "XDM_REPOSITORY_PASSWORD"
          value = "semarchy_repository"
        },
        {
          name  = "XDM_REPOSITORY_READONLY_USERNAME"
          value = "semarchy_repository_ro"
        },
        {
          name  = "XDM_REPOSITORY_READONLY_PASSWORD"
          value = "semarchy_repository_ro"
        },
        {
          name  = "SEMARCHY_SETUP_TOKEN"
          value = "mySecretValue"
        },
        {
          name  = "CONTEXT_PATH"
          value = "/semarchy"
        }
      ],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
])
}

resource "aws_ecs_service" "main" {
    name            = "cb-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.app.arn
    desired_count   = var.app_count
    launch_type     = "FARGATE"
    force_new_deployment = true

    network_configuration {
        security_groups  = [aws_security_group.ecs_tasks.id]
        subnets          = aws_subnet.private_subnets.*.id
        assign_public_ip = true
    }

    load_balancer {
        target_group_arn = aws_alb_target_group.app.id
        container_name   = "cb-app"
        container_port   = var.app_port
    }

}