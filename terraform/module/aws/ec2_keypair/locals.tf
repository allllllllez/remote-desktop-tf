locals {
  # 公開鍵ファイルパス
  public_key_file = "./${var.key_name}.id_rsa.pub"
  # 秘密鍵ファイルパス
  private_key_file = "./${var.key_name}.id_rsa"
}
