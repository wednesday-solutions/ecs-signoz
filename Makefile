hello:
	echo "hello world"
deploy-signoz-standard:
	./setup-scripts.sh ./setup-script.sh signoz dev otel query alery frontend
deploy-clickhouse:
	./setup-clickhouse.sh	
fluentbit-upload:
	./scripts/register-fluent.sh
clickhouse:
	./scripts/clickhouse.sh		
