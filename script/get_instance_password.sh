#!/usr/bin/bash
# set -x

# 
# EC2 インスタンスのインスタンスIDとパスワードを取得するやつ
# 
# Requirements：
#     * AWS CLI(クレデンシャルは環境変数で設定してくれよな)
# 

REGION="us-west-2"
INSTANCE_NAME="ec2_windows_vpc"
KEYPAIR_FILE_NAME="ec2_windows_vpc.id_rsa"


# スクリプトからの相対パスで鍵ファイルの場所を取得
SCRIPT_DIR="$(dirname $0)"
KEYPAIR_FILE_PATH="${SCRIPT_DIR}/../terraform/${KEYPAIR_FILE_NAME}"

instance_info=$(
    aws ec2 describe-instances --region $REGION \
        | jq '.[][]["Instances"][] 
            | select(.KeyName == "'$INSTANCE_NAME'")
            | {"KeyName", "InstanceId", "PublicDnsName"}'
)
if [[ -z "$instance_info" ]]; then
    echo "failed to get instance infomation."
    return 1
fi
echo "Instance ${INSTANCE_NAME}:"
echo "$instance_info"

instance_id=$(
    echo $instance_info | jq -r '.InstanceId'
)
passwd_data=$(
    aws ec2 get-password-data \
        --priv-launch-key $KEYPAIR_FILE_PATH \
        --region $REGION \
        --instance-id $instance_id
)
echo "Password data:"
echo "$passwd_data"
