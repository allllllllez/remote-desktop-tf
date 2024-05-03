locals {
  # setup script"
  user_data = <<-EOF
  # VNCで接続するために、Apple Remote Desktop エージェントの起動とアクセス許可を行う
  sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
      -activate \
      -configure \
      -access -on \
      -clientopts \
      -setvnclegacy \
      -vnclegacy yes \
      -clientopts \
      -setvncpw \
      -vncpw  ${var.vnc_password} \
      -restart \
      -agent \
      -privs -all 
  EOF
}
