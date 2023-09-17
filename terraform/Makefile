help: ## Usage
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

TERRAFORM_TFVARS:=vars.tfvars
TERRAFORM_PLAN_LOG:=terraform_plan.log
TERRAFORM_APPLY_LOG:=terraform_apply.log
TERRAFORM_DESTROY_LOG:=terraform_destroy.log

validate: ## terraform validate
	terraform validate

format: ## terraform fmt
	terraform fmt -write -recursive

plan: format validate ## terraform plan
	terraform plan -no-color -var-file $(TERRAFORM_TFVARS) -no-color > $(TERRAFORM_PLAN_LOG) 2>&1

apply: ## terraform apply
	terraform apply --auto-approve -no-color -var-file $(TERRAFORM_TFVARS) -no-color > $(TERRAFORM_APPLY_LOG) 2>&1

destroy: ## terraform destroy
	terraform destroy -auto-approve -var-file $(TERRAFORM_TFVARS) -no-color > $(TERRAFORM_DESTROY_LOG) 2>&1
