resource "aws_ecs_cluster" "main_cluster" {
  name = "flask-express-cluster"
}

resource "aws_default_vpc" "default_vpc" {

}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "ap-south-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "ap-south-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "ap-south-1c"
}

resource "aws_ecs_task_definition" "flask" {
  family                   = "flask-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions =   <<DEFINITION
  [
    {
      "name": "flask-container",
      "image": "${var.flask_repo_url}:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "environment" : [
        {
          "name": "MONGO_URL",
          "value": "mongodb+srv://connection<string>"
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_task_definition" "express" {
  family                   = "express-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions =  <<DEFINITION
  [
    {
      "name": "express-container",
      "image": "${var.express_repo_url}:latest",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "environment" : [
        {
          "name": "BACKEND_URL",
          "value": "http://${aws_lb.application_load_balancer.dns_name}:8080"
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_lb" "application_load_balancer" {
  name               = "flask-express-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
}

resource "aws_security_group" "load_balancer_security_group" {
  name   = "load-balancer-security-group"
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "flask_target_group" {
  name        = "flask-target-group"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}

resource "aws_lb_target_group" "express_target_group" {
  name        = "express-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}

resource "aws_lb_listener" "flask_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flask_target_group.arn
  }
}

resource "aws_lb_listener" "express_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.express_target_group.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.application_load_balancer.dns_name
}

resource "aws_ecs_service" "flask_service" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.flask.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_target_group.arn
    container_name   = "flask-container"
    container_port   = 5000
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
    security_groups  = [aws_security_group.service_security_group.id]
    assign_public_ip = true
  }
}

resource "aws_ecs_service" "express_service" {
  name            = "express-service"
  cluster         = aws_ecs_cluster.main_cluster.id
  task_definition = aws_ecs_task_definition.express.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.express_target_group.arn
    container_name   = "express-container"
    container_port   = 3000
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
    security_groups  = [aws_security_group.service_security_group.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "service_security_group" {
  name        = "service-security-group"
  vpc_id      = aws_default_vpc.default_vpc.id
  description = "Security group for service containers"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
