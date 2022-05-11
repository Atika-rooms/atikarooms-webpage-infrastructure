HELP_FUN = \
		 %help; \
		 while(<>) { \
		 	push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z0-9_-]+)\s*:.*\#\#(?:@(\w+))?\s(.*)$$/ \
		 }; \
		 print "usage: make [target]\nexample: make help\n\n"; \
		 for ( sort keys %help ) { \
		 	print "$$_:\n"; \
			printf("  %-20s %s\n", $$_->[0], $$_->[1]) for @{$$help{$$_}}; \
			print "\n"; \
		 }

help: ##@miscellaneous Show this help
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

start: ##@Containers Creates and enter to the development container
	@make up && make enter
up: ##@Containers Creates the development container
	@docker-compose up --detach development
enter: ##@Containers Enters to the development container
	@docker-compose exec --user $(shell id -u):$(shell id -g) development bash
build: ##@Containers Forces to build the development container
	@docker-compose build development
stop: down ##@Containers Stops the container
down: ##@Containers Stops the container
	@docker-compose down
destroy: ##@Containers Removes the container and all its resources
	@docker-compose down --rmi all --volumes

mk-init:
	@terraform -chdir=terraform/environments/${ENV} init
init-testing: ##@Terraform Initializes Testing state
	@make -s ENV=testing mk-init
init-production: ##@Terraform Initializes Production state
	@make -s ENV=production mk-init

init-all:
	@echo "Initializing testing..." && make -s init-testing
	@echo "Initializing production..." && make -s init-production

mk-validate:
	@terraform -chdir=terraform/environments/${ENV} validate
validate-testing: ##@Terraform Executes the Testing environment validation
	@make -s ENV=testing mk-validate
validate-production: ##@Terraform Executes the Production environment validation
	@make -s ENV=production mk-validate

validate-all:
	@echo "Validating testing..." && make -s validate-testing
	@echo "Validating production..." && make -s validate-production

mk-plan:
	@terraform -chdir=terraform/environments/${ENV} plan 
plan-testing: ##@Terraform Executes the Testing environment plan
	@make -s ENV=testing mk-plan
plan-production: ##@Terraform Executes the Production environment plan
	@make -s ENV=production mk-plan

plan-all:
	@echo "Planing testing..." && make -s plan-testing
	@echo "Planing production..." && make -s plan-production
fmt: ##@Terraform Executes a terraform fmt in all directories
	@terraform fmt -diff -recursive terraform/

mk-lint:
	@cd terraform/environments/${ENV}/ && \
	tflint --config /code/tools-config/.tflint.hcl \
	--var-file=${ENV}.auto.tfvars
lint-init:
	@tflint --init --config tools-config/.tflint.hcl
lint-testing: ##@Tests Linter for Testing
	@make -s lint-init
	@make -s ENV=testing mk-lint
lint-production: ##@Tests Linter for Production
	@make -s lint-init
	@make -s ENV=production mk-lint

lint-all:
	@echo "Linting testing..." && make -s lint-testing
	@echo "Linting production..." && make -s lint-production

mk-sec:
	@cd terraform/environments/${ENV}/ && \
	tfsec --config-file /code/tools-config/.tfsec.yml --custom-check-dir /code/tools-config/tfsec-custom-checks/ \
	--tfvars-file=${ENV}.auto.tfvars
sec-testing: ##@Tests Security checks for Testing
	@make -s ENV=testing mk-sec
sec-production: ##@Tests Security checks for Production EU
	@make -s ENV=production mk-sec

sec-all:
	@echo "Passing security checks on testing..." && make -s sec-testing
	@echo "Passing security checks on production..." && make -s sec-production


test: ##@Tests Executes a 'fmt' checker, a validation, a linting and a plan for all compositions
	@terraform fmt -check -diff -recursive terraform/
	@make -s validate-all
	@make -s lint-all
	@make -s plan-all
test-testing:
	@terraform fmt -check -diff -recursive terraform/environments/testing
	@make -s validate-testing
	@make -s lint-testing
	@make -s plan-testing
test-production:
	@terraform fmt -check -diff -recursive terraform/environments/production
	@make -s validate-production
	@make -s lint-production
	@make -s plan-production
