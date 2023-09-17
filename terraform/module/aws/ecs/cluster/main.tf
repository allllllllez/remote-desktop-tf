# Cluster
resource "aws_ecs_cluster" "windows_cluster" {
  name = var.cluster_name

  tags = {
    Name = var.tag_name
  }
}

# ECS Cluster用 IAMロール
resource "aws_iam_role" "cluster_role" {
  name = var.cluster_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_role_policy_attachment" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# インスタンスプロファイル 
resource "aws_iam_instance_profile" "cluster_instance_profile" {
  name = var.cluster_instance_profile_name
  role = aws_iam_role.cluster_role.name
}

