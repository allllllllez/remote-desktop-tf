SHELL=/bin/bash
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))


help: ## Usage
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

docker_build: ## docker image build: tf_sandbox
	log_file="docker-compose__build__tf_sandbox.log"
	docker compose build tf_sandbox > ${log_file} 2>&1
	tail -n 5 "${log_file}"

docker_run: ## docker run: tf_sandbox 
	docker compose run \
		--env TF_VAR_my_ip_address="$(curl -s ipinfo.io | jq -r .ip)/32" \
		tf_sandbox

ecc_ssh: ## SSH Connect to EC2, Requirements: INSTANCE_ID=<instance-id>
	if [[ -z "@(INSTANCE_ID)" ]]; then echo "Requirements: INSTANCE_ID=<instance-id>"; return 1; fi
	aws ec2-instance-connect ssh \
		--connection-type eice \
		--region us-west-2 \
		--instance-id "@(INSTANCE_ID)" 
