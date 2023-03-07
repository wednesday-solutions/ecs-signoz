This template allows you to deploy signoz on aws ecs fargate. [(what is signoz?)](https://signoz.io/)

Signoz provides comprehensive monitoring for your ECS Fargate service. It tracks and monitors all the important metrics and logs related to your application, infrastructure, and network, and provides real-time alerts for any issues.

Self hosting signoz on aws ecs fargate is also significantly cheaper than using aws native services like xray and cloudwatch to collect metrics,traces and logs.Signoz consists of a clikhouse cluster and multiple services which, hosting them is tedious and inconvenient but this template allows you to do so using a single command.

### Pre-Requisites:

1. please have bash utility jq installed to process json.[To install](https://stedolan.github.io/jq/download/)
2. please have bash utility yq installed to process yml. [To install](https://github.com/mikefarah/yq)
3. please install the aws cli and docker.[To install docker  ](https://docs.docker.com/engine/install/) [To install aws-cli  ](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
4. Please have aws cli configured with access key,secret and region. [To configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
5. please have aws copilot version of the current develop branch on github.[To install - use make to install a standalone binary](https://github.com/aws/copilot-cli/blob/eda606604b61a4b00cdf0de4847784eb7a633b7d/CONTRIBUTING.md#environment)
6. please configure signoz-ecs-config.yml.




In this template we are using cloudformation to host our clickhouse cluster and aws copilot to host our services on ecs fargate.
---
### Hosting a clickhouse cluster using aws cloudformation:

The template can be configured if you want to create a new vpc for our clickhouse-cluster or create the cluster in an existing vpc.
To create the cluster in an existing vpc just toggle the value of existing vpc to true.
                                        signoz-app:
                                            existing-vpc: "true"

When existing-vpc option is toggled false it will create the following resources:

![clickhouse.yaml resources diagram ](./images/click-complete.png "Title")

This will create a new vpc with two private subnets and two public subnets. We will host 3 zookeeper instances and 3 shards of clickhouse instacnce in our private subnets. This will also host a bastion instance in our public instance if we ever want to ssh into our instaces to debug some issues.


When existing-vpc option is toggled true:

You will also have to configure vpc id,public and private subnets option in signoz-ecs-config.yml file

                                        signoz-app:
                                            public-subnet-a-id: ""
                                            public-subnet-b-id: ""
                                            private-subnet-a-id: ""
                                            private-subnet-b-id: ""
                                            vpc-id: ""


![clickhouse-custom-vpc.yaml resources diagram ](./images/click-custom.png "Title")
![clickhouse-custom-vpc.yaml parameters](./images/click-custom-param.png "Title")

This creates three zookeeper instances and three clickhouse shards in private subnets of your vpc.

If you are using a managed clickhouse-service, you can mention the host of one of the shards, then will not create it's own clickhouse cluster(on port 9000):
                                        signoz-app:
                                            clickhouse-host-name: ""
                                            

You can use custom ami's for zookeeper or clickhouse instances if your organization has special security needs or want to add more functionality (we have made our own [user-data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) scripts, so each clichouse shard and zookeeper can know about each other at start time). If you do not want to copy your ami's outside of a single region just replace the _ImageId_ field. If you want to copy ami's to all region then use ./scripts/copy-ami.sh script and ./scripts/amimap.sh to generate the mappings,then replace the existing mappings with the output.

---

Why are we using aws copilot?

AWS Copilot CLI simplifies the deployment of your applications to AWS. It automates the process of creating AWS resources, configuring them, and deploying your application. This can save you time and effort compared to manual deployment.It simplifies the deployment of your applications to AWS. It automates the process of creating AWS resources, configuring them, and deploying your application. This can save you time and effort compared to manual deployment.
Aws copilot will allow us to deploy all our signoz services with minimum configuration

You are free to use your own custon vpc and subnets, though they should be the same as your clickhouse cluster(if hosting in a private subnet).
You will also have to configure vpc id,public and private subnets option in signoz-ecs-config.yml file

                                        signoz-app:
                                            public-subnet-a-id: ""
                                            public-subnet-b-id: ""
                                            private-subnet-a-id: ""
                                            private-subnet-b-id: ""
                                            vpc-id: ""






#### Configuring values in signoz-ecs-config.yml

1. If your want to use an existing vpc keep the value of existing-vpc other than true.
2. You can change the name of any of the services if you want to.
3. You can change the name of cloudformation stack of your clickhouse cluster
4. can change the instance type of your clikhouse or zookeeper hosts
5. can change the environment name and application name for the copilot cli.

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
    

