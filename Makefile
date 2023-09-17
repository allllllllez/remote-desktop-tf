MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))


help: ## Usage
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

docker_build: ## docker image build: tf_sandbox
	log_file="docker-compose__build__tf_sandbox.log"
	docker-compose build tf_sandbox > ${log_file} 2>&1
	tail -n 5 "${log_file}"

docker_run: ## docker run: tf_sandbox 
	docker-compose run --rm tf_sandbox
