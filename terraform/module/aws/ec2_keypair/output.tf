# キーペア名
output "key_pair_name" {
  value = aws_key_pair.windows_server_key_pair.key_name
}

# 秘密鍵ファイルPATH（このファイルを利用してサーバへアクセスする。）
output "private_key_file" {
  value = local.private_key_file
}

# 秘密鍵内容
output "private_key_pem" {
  value = tls_private_key.keygen.private_key_pem
}

# 公開鍵ファイルPATH
output "public_key_file" {
  value = local.public_key_file
}

# 公開鍵内容（サーバの~/.ssh/authorized_keysに登録して利用する。）
output "public_key_openssh" {
  value = tls_private_key.keygen.public_key_openssh
}
