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

start: ##@containers Creates and enter to the development container
	@make up && make enter
up: ##@containers Creates the development container
	@docker-compose up --detach development
enter: ##@containers Enters to the development container
	@docker-compose exec --user $(shell id -u):$(shell id -g) development bash
build: ##@containers Forces to build the development container
	@docker-compose build development
down: ##@containers Destroys all containers
	@docker-compose down

plan-testing: ##@terraform Executes the Testing environment plan
	@terraform -chdir=terraform/environments/testing plan -var-file=testing.tfvars
plan-production: ##@terraform Executes the Production environment plan
	@terraform -chdir=terraform/environments/production plan -var-file=production.tfvars
fmt: ##@terraform Executes a terraform fmt in all directories
	@terraform fmt -diff -recursive terraform/