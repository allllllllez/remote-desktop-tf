# クラスターID
output "cluster_id" {
  value = aws_ecs_cluster.windows_cluster.id
}

# クラスター用ロールのインスタンスプロファイル
output "cluster_instance_profile_name" {
  value = aws_iam_instance_profile.cluster_instance_profile.name
}
