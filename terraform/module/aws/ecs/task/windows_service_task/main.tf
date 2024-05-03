resource "aws_ecs_task_definition" "windows_service" {
  family = "windows-simple-iis"
  # サンプルのママ：https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ECS_Windows_getting_started.html
  container_definitions = <<-EOF
  [
    {
      "name": "windows_sample_app",
      "image": "microsoft/iis",
      "cpu": 512,
      "entryPoint":[
        "powershell", "-Command"
      ],
      "command":[
        "New-Item -Path C:\\inetpub\\wwwroot\\index.html -ItemType file -Value '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p>' -Force ; C:\\ServiceMonitor.exe w3svc"
      ],
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": 80,
          "hostPort": 8080
        }
      ],
      "memory": 768,
      "essential": true
    }
  ]
  EOF
}

resource "aws_ecs_service" "windows_service" {
  launch_type         = "EC2"
  task_definition     = aws_ecs_task_definition.windows_service.arn
  cluster             = var.cluster_id
  name                = var.service_name
  scheduling_strategy = "REPLICA"

  desired_count = 3

  ordered_placement_strategy {
    field = "attribute:ecs.availability-zone"
    type  = "spread"
  }
  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }

  tags = var.tags
}

# ECS task実行用Role
# もしかして：いらない
resource "aws_iam_role" "task_role" {
  name = "task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_instance_profile" "windows_task_instance_profile" {
  name = var.task_instance_profile_name
  role = aws_iam_role.task_role.name
}
