FROM ubuntu:24.04

################################################################################
# Arguments
################################################################################
# terraform version
ARG terraform_version="1.8.2"

################################################################################
# Install
################################################################################
# エラー対策（A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond. [IP: 91.189.91.82 80]）
# chattr -i /etc/resolv.conf && echo nameserver 8.8.8.8 | tee /etc/resolv.conf && \
RUN apt update && \
  apt upgrade -y && \
  apt install -y sudo make curl unzip vim jq git && \
  # Install awscliv2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  rm -rf awscliv2.zip && \
  sudo ./aws/install && \
  # Install terraform
  curl -O "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip" && \
  unzip ./terraform_${terraform_version}_linux_amd64.zip -d /usr/local/bin/ && \
  rm -rf ./terraform_${terraform_version}_linux_amd64.zip

ENTRYPOINT /bin/bash
