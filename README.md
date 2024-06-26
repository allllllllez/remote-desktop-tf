# Run remote desktop instance by Terraform 

Remote Desktop で接続可能な EC2 インスタンス（キーペア付き）+ Security Group をパパっと立てるやつ

## ファイル構成

| ファイル・フォルダ名 | 説明 |
| :- | :- |
| terraform | terraform ソース置き場 |
| script | スクリプト置き場 |
| images | README 用画像 |
| Dockerfile | Terraform 実行環境イメージ設定ファイル |
| docker-compose.yml | Terraform 実行環境コンテナ設定ファイル |

## つかいかた

### 環境変数設定

`.aws/credentials` に、AWSのcredential情報を記載してください

```bash
[default]
aws_access_key_id = <your-access-key>
aws_secret_access_key = <your-secret-key>
```

(Optional) [Pluralith](https://www.pluralith.com/) を使用して構成図を出す場合、`.env` の `PLURALITH_API_KEY` にAPIキーを指定してください。

### Terraform 実行環境

docker コンテナを起動してください。

起動コマンド例）

```
$ docker compose run \
    --env TF_VAR_my_ip_address="$(curl -s ipinfo.io | jq -r .ip)/32" \
    tf_sandbox
```

※ `TF_VAR_my_ip_address` は `.env` に記載してもOK

### EC2起動

```
~/work/docker_windows_on_ec2/terraform # terraform init
（出力略）
~/work/docker_windows_on_ec2/terraform # terraform apply
```

### インスタンスへ接続
#### ssh

EC2 instance connect endpoint を使用して接続します。

```bash-session
# aws ec2-instance-connect ssh \
>         --connection-type eice \
>         --region us-west-2 \
>         --instance-id "i-xxxxxxxxxxxxxxxx"
The authenticity of host 'xx.x.x.xx (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'xx.x.x.xx' (ED25519) to the list of known hosts.
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
```

#### Windows RDP

Windowsのリモートデスクトップで接続してみます。

パスワードは、「Windows パスワードを取得」で、作成したキーペアを復号して入手します。

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

リモートデスクトップを起動します。
「リモートデスクトップファイルのダウンロード」でRDPショートカットファイルを入手すると、ショートカットを実行するだけでOKになります。

ダウンロードしなくても、上のコマンドで表示した「PublicDNSName」をコピーして、RDPの接続先に指定すればよいです。

<img src="./images/readme_rdp_parameter.png" width=400>

接続すると、パスワード入力を要求される。

<img src="./images/readme_rdp_password.png" width=400>

パスワードを入力して「OK」押下。

<img src="./images/readme_rdp_logon.png" width=400>

接続できた。

##### 何かしてみる

Windows で user_data に [user_data_win.ps1](./terraform/user_data_win.ps1) を使うと、インストールを仕込んでいるので git が使えたりします。

<img src="./images/readme_remote_git.png" width=800>

<img src="./images/readme_remote_git_clone.png" width=800>

#### Mac OS 

<details>
<summary>WIP</summary>

```
$  ssh -i "mac_os_in
stance.id_rsa" ec2-user@ec2-35-92-143-188.us-west-2.c
ompute.amazonaws.com

    ┌───┬──┐   __|  __|_  )
    │ ╷╭╯╷ │   _|  (     /
    │  └╮  │  ___|\___|___|
    │ ╰─┼╯ │  Amazon EC2
    └───┴──┘  macOS Ventura 13.5.2

ec2-user@ip-10-0-0-223 ~ %
```

```tf
vnc_password = "xxxxx"
```

を入力

</details>

## EC2 構成図

### Windows インスタンス

<img src="./images/readme_windows_instance_resources.png" width=800>

