### Pre-Requisites:

1. please have bash utility jq installed to process json
2. please have bash utility yq installed to process yml
3. please install the aws cli and docker
4. Please have aws cli configured with access key,secret and region
5. please have aws copilot version of the current develop branch on github
6. please configure signoz-ecs-config.yml

### To deploy aws on ecs sigoz:

#### If you want to deploy from scratch - to deploy your own vpc,clickhouse cluster and fargate cluster

configure signoz-ecs-config.yml

Then execute the script with 
```
make deploy
```

#### If you want to deploy clickhouse cluster and services in your own vpc:

configure vpc id and subnet id in signoz-ecs-config.yml
make the value of variable existing-vpc to yes
add the vpc id and all the subnets id

```
make deploy
```
#### If you have already deployed clickhouse cluster and want to deploy all services in a new vpc and fargate cluster:

configure the clichouse host in signoz-ecs-config.yml

```
make deploy
```

#### If you have already deployed clickhouse cluster and want to deploy all services in an existing vpc:

configure the clichouse host in signoz-ecs-config.yml
configure vpc id and subnet id in signoz-ecs-config.yml

```
make deploy
```

#### If you have already configured copilot with an app name and environment(the subnets should the same where clickhouse is present):

configure the clichouse host in signoz-ecs-config.yml
configure vpc id and subnet id in signoz-ecs-config.yml

```
make deploy-existing-copilot-app
```


To scaffold a service with a sample file use command:

```
make scaffold $service-name
```