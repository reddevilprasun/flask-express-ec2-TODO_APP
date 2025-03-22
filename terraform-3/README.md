
### ECS Cluster
```hcl
resource "aws_ecs_cluster" "main_cluster" {
  name = "flask-express-cluster"
}
```
- **aws_ecs_cluster**: Defines an ECS cluster where the services will run. This is where the Flask and Express applications will be deployed.

### VPC and Subnets
```hcl
resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "ap-south-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "ap-south-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "ap-south-1c"
}
```
- **aws_default_vpc**: A default Virtual Private Cloud (VPC) to create networking resources like subnets and security groups.
- **aws_default_subnet**: Three subnets are created in different availability zones within the VPC, ensuring high availability for the services. These subnets allow tasks to be distributed across multiple zones.

### ECS Task Definitions
#### Flask Task Definition
```hcl
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
          "value": "mongodb+srv://<mongo-credentials>"
        }
      ]
    }
  ]
  DEFINITION
}
```
- **aws_ecs_task_definition**: Defines a task (the smallest unit in ECS) that will run the Flask application.
  - `requires_compatibilities`: Specifies that this task will run on Fargate, AWS's serverless compute engine.
  - `cpu`, `memory`: Allocates 256 CPU units and 512MB of memory to the task.
  - `container_definitions`: Contains details about the Flask container, such as the image (`${var.flask_repo_url}:latest`), port mappings, and environment variables.

#### Express Task Definition
```hcl
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
```
- This task definition is for the Express app, with similar configuration as the Flask task, but the container runs on port 3000.
- `BACKEND_URL`: An environment variable referencing the load balancer's DNS.

### IAM Role for ECS Task Execution
```hcl
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
```
- **aws_iam_role**: Defines an IAM role for ECS tasks to interact with other AWS services (e.g., pulling container images from ECR).
- **aws_iam_role_policy_attachment**: Attaches the `AmazonECSTaskExecutionRolePolicy` which allows ECS tasks to use services like Amazon CloudWatch Logs, ECR, etc.

### Load Balancer and Security Group
```hcl
resource "aws_lb" "application_load_balancer" {
  name               = "flask-express-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
}
```
- **aws_lb**: This defines an Application Load Balancer (ALB) that distributes incoming traffic to ECS services (Flask and Express).
- **internal = false**: Makes the ALB publicly accessible.
- **security_groups**: Associates the load balancer with a security group for ingress and egress traffic.
- **subnets**: Assigns the ALB to the three defined subnets for availability.

#### Security Group for Load Balancer
```hcl
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
- **aws_security_group**: Defines the security group for the ALB.
  - **ingress**: Allows inbound HTTP traffic on ports 80 and 8080 from any IP address (`0.0.0.0/0`).
  - **egress**: Allows all outbound traffic.

### Load Balancer Target Groups
```hcl
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
```
- **aws_lb_target_group**: Defines target groups for the Flask and Express services. The ALB routes traffic to the containers based on port mappings (5000 for Flask, 3000 for Express).

### ALB Listeners
```hcl
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
```
- **aws_lb_listener**: Configures listeners for the ALB to handle HTTP traffic on ports 80 (for Express) and 8080 (for Flask). Each listener forwards traffic to its respective target group.

### ECS Services
```hcl
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


    security_groups  = [aws_security_group.load_balancer_security_group.id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.flask_listener]
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
    security_groups  = [aws_security_group.load_balancer_security_group.id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.express_listener]
}
```
- **aws_ecs_service**: Defines the ECS service that manages the Flask and Express containers.
  - **launch_type**: Specifies that the service runs on Fargate.
  - **desired_count**: Sets the number of tasks to run (1 for now).
  - **load_balancer**: Connects the service to the ALB and specifies the target group and container details.
  - **network_configuration**: Specifies the VPC subnets and security group for the service, with public IP assignment.

---

### Environment Variables
Replace the placeholders in the environment variables with the actual values, such as the MongoDB credentials (`<mongo-credentials>`) and the URLs for the Flask and Express Docker images (`var.flask_repo_url`, `var.express_repo_url`).

This Terraform configuration deploys a Flask and Express app using AWS Fargate, with an Application Load Balancer to manage incoming traffic, ensuring scalability and availability of both applications.