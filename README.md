## Windows on EC2

EC2 インスタンスをパパっと立てるやつ

## つかいかた

### EC2起動

```
~/work/docker_windows_on_ec2/terraform # terraform init
（出力略）
~/work/docker_windows_on_ec2/terraform # terraform apply
```

### インスタンスへ接続

Windowsのリモートデスクトップで接続する。

パスワードは、「Windows パスワードを取得」で、作成したキーペアを復号して入手する。

<img src="./images/readme_console_keypair.png" width=800>

AWS CLIでも入手可能。コマンドは[docker_windows_on_ec2/script/get_instance_password.sh](script/get_instance_password.sh)を参照されたい。
```
root@ec1476751abe:~/work/terraform# ../script/get_instance_password.sh
Instance windows_server:
{
  "KeyName": "windows_server",
  "InstanceId": "i-01c0d14297b0bda64",
  "PublicDnsName": "ec2-34-212-0-222.us-west-2.compute.amazonaws.com"
}
Password data:
{
    "InstanceId": "i-01c0d14297b0bda64",
    "PasswordData": "*********************************,
    "Timestamp": "2023-09-05T15:30:58+00:00"
}
```

リモートデスクトップを起動する。
「リモートデスクトップファイルのダウンロード」でRDPショートカットファイルを入手すると、ショートカットを実行するだけでOK。

ダウンロードしなくても、上のコマンドで表示した「PublicDNSName」をコピーして、RDPの接続先に指定すればよい。

<img src="./images/readme_rdp_parameter.png" width=400>

接続すると、パスワード入力を要求される。

<img src="./images/readme_rdp_password.png" width=400>

パスワードを入力して「OK」押下。

<img src="./images/readme_rdp_logon.png" width=400>

接続できた。

### 何かしてみる

user_data でインストールを仕込んでいるので git が使えたりする。

<img src="./images/readme_remote_git.png" width=800>

