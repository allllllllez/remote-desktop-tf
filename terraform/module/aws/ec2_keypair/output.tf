output "key_pair_name" {
  value       = aws_key_pair.windows_server_key_pair.key_name
  description = "キーペア名"
}

output "private_key_file" {
  value       = local.private_key_file
  description = "秘密鍵ファイルへのパス"
}

output "private_key_pem" {
  value       = tls_private_key.keygen.private_key_pem
  description = "秘密鍵内容"
}

output "public_key_file" {
  value       = local.public_key_file
  description = "公開鍵ファイルへのパス"
}

output "public_key_openssh" {
  value       = tls_private_key.keygen.public_key_openssh
  description = "公開鍵内容。サーバの~/.ssh/authorized_keysに登録して利用する"
}
