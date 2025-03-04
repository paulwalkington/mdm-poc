data "aws_caller_identity" "current" {}

variable "aws_region" {
    description = "The AWS region things are created in"
    default = "eu-west-2"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}


variable "ec2_task_execution_role_name" {
    description = "ECS task execution role name"
    default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
    description = "ECS auto scale role name"
    default = "myEcsAutoScaleRole"
}

variable "az_count" {
    description = "Number of AZs to cover in a given region"
    default = 2
}

variable "app_image" {
    description = "Docker image to run in the ECS cluster"
    default = "nginxdemos/hello:latest"
}

variable "app_port" {
    description = "Port exposed by the docker image to redirect traffic to"
    default = 80

}

variable "app_count" {
    description = "Number of docker containers to run"
    default = 3
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = 1024
}

variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = 2048
}
