From signoz/alertmanager:${ALERTMANAGER_TAG:-0.23.0-0.2} 





Copy ./data/alertmanager /data


# CMD ["--queryService.url=http://signo-publi-pyw7y8wsube3-a6af62bf5764a750.elb.ap-southeast-1.amazonaws.com:8080/","--storage.path=/data"]
CMD ["--queryService.url=http://query-svc.dev-signoz.signoz-deploy-app.local:8085","--storage.path=/data"]


EXPOSE 9093

