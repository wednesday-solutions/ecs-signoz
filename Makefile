hello:
	echo "hello world"
deploy:
	./scripts/setup-files.sh
	./scripts/deploy-env.sh
	./scripts/deploy-service.sh
	./scripts/register-fluent.sh
deploy-existing-copilot-app:
	./scripts/setup-files.sh
	./scripts/deploy-service.sh
	./scripts/register-fluent.sh

deploy-clickhouse:
	./setup-clickhouse.sh	
scaffold:
	./scripts/scaffolding.sh $(svc)
fluentbit-upload:
	./scripts/register-fluent.sh
clickhouse:
	./scripts/clickhouse.sh		
delete:
	./scripts/cleanup-services.sh  
	./scripts/cleanup-clickhouse.sh 	
delete-all:
	./scripts/cleanup-app.sh  
	./scripts/cleanup-clickhouse.sh 