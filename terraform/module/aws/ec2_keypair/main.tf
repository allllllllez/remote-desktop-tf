# 
#  EC2 key pair 
# 

# キーペアを作る
resource "tls_private_key" "keygen" {
  algorithm = "ED25519"
}

# 秘密鍵ファイルを作る
resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.keygen.private_key_pem

  # local_fileでファイルを作ると実行権限が付与されてしまうので、local-execでchmodしておく。
  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_file}"
  }
}

resource "local_file" "public_key_openssh" {
  filename = local.public_key_file
  content  = tls_private_key.keygen.public_key_openssh

  # local_fileでファイルを作ると実行権限が付与されてしまうので、local-execでchmodしておく。
  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_file}"
  }
}

# EC2 key pair
resource "aws_key_pair" "windows_server_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.keygen.public_key_openssh
}
