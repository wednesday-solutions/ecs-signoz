### Pre-Requisites:

1. please have bash utility jq installed to process json.[To install](https://stedolan.github.io/jq/download/)
2. please have bash utility yq installed to process yml. [To install](https://github.com/mikefarah/yq)
3. please install the aws cli and docker[To install](https://github.com/mikefarah/yq)
4. Please have aws cli configured with access key,secret and region
5. please have aws copilot version of the current develop branch on github
6. please configure signoz-ecs-config.yml

### To deploy aws on ecs sigoz:

(Please keep the value of clickhouse host blank if you want to deploy a new cluster in your vpc)


#### If you want to deploy from scratch - to deploy your own vpc,clickhouse cluster and fargate cluster

first configure signoz-ecs-config.yml with appropriate values(do not change the value of existing-vpc=no)

Then execute the script with 
```
make deploy
```

#### If you want to deploy clickhouse cluster and services in your own vpc:

configure vpc id and subnet id in signoz-ecs-config.yml
make the value of variable existing-vpc to true
add the vpc id and all the subnets id

```
make deploy
```
#### If you have already deployed clickhouse cluster and want to deploy all services in a new vpc and fargate cluster:

configure the clickhouse host in signoz-ecs-config.yml

```
make deploy
```

#### If you have already deployed clickhouse cluster and want to deploy all services in an existing vpc:

configure the clichouse host in signoz-ecs-config.yml
configure vpc id and subnet id in signoz-ecs-config.yml

```
make deploy
```

#### If you have already configured copilot with an app name and environment(the subnets should be the same as the one where clickhouse cluster is present):

configure the clickhouse host in signoz-ecs-config.yml
configure vpc id and subnet id in signoz-ecs-config.yml

```
make deploy-existing-copilot-app
```


To scaffold a service with a sample file use command:

```
make scaffold $service-name
```

To use your own custom ami's for clickhouse and zookeeper  :
 
    you can copy the ami's in all region using the script :
    ```
    ./scripts/copy-ami.sh
    ```

    then you can use the script to get a mapping of all ami's using:
    ```
    ./scripts/amimap.sh
    ```
    Then replace the mappings in the clickhouse.yml cloudformation template
    

