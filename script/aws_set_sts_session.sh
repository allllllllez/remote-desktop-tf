#! /usr/bin/env bash
set -x

# 
# MFA認証が必要なAWS環境でAWS CLIを使うため、一時的な認証情報を設定するスクリプトを作成する
# 
# Requirements:
# * AWSアカウント情報（アカウントID、IAMユーザー名、credentials環境変数）
# * MFA認証コード
# 

# 
# Variables
# 
aws_profile="default"
aws_account_id="921407950230"
aws_user_name="m.kajiya"
# myname=$(basename $0)
region="ap-northeast-1"

# 
# Functions
# 
usage() {
    cat << EOS
Description:
    一時的な認証情報を設定するスクリプトを作成する。
    MFA認証が必要なAWS環境でAWS CLIを使うためのもの

Usage:
    $myname <token_code> [<aws_user_name>] [<aws_account_id>]
    
Parameters:
    <token_code>
        MFAデバイスで取得した確認コード
    <aws_user_name>
        AWSにサインインするユーザー名
    <aws_account_id>
        AWSアカウントID。デフォルトは 921407950230（社内AWSアカウント）

Output:
    ./.env
        一時的な認証情報を設定するスクリプト。 $ source ./.env でどうぞ
EOS
}

token_code=$1
if [[ -z "$token_code" ]]; then
    echo "Please specify MFA token code."
    usage
    exit 1
fi

if [[ ! -z $2 ]]; then aws_user_name=$2; fi

if [[ -z "$aws_user_name" ]]; then
    echo "Please specify AWS user name."
    usage
    exit 1
fi

aws_account_id=$(if [[ -z "$3" ]]; then echo "${aws_account_id}"; else echo "$3"; fi)

# 期限が切れたAWS_SESSION_TOKENが設定されていると、awsコマンドがエラーになる
unset AWS_SESSION_TOKEN

ret_session=$(aws sts get-session-token \
    --serial-number arn:aws:iam::${aws_account_id}:mfa/${aws_user_name} \
    --duration-seconds 129600 --token-code "$token_code" \
    --profile ${aws_profile} --region ${region})

cat << EOS >> .envrc

# セッション再取得用にもとのcredentialを吐いておく
# export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
# export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_ACCESS_KEY_ID=$(echo "${ret_session}" | jq -r ."Credentials"."AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(echo "${ret_session}" | jq -r ."Credentials"."SecretAccessKey")
export AWS_SESSION_TOKEN=$(echo "${ret_session}" | jq -r ."Credentials"."SessionToken")
EOS
