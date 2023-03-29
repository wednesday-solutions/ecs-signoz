### This template allows you to deploy SigNoz on aws ecs fargate. [(what is signoz?)](https://signoz.io/)

## Table of contents
* [About SigNoz](#about-signoz)
* [Pre-requisites](#pre-requisites)
* [Config-File](#config-file)
* [Hosting clickhouse using cloudformation](#hosting-a-clickhouse-cluster-using-aws-cloudformation)
* [Using AWS Copilot](#why-are-we-using-aws-copilot)
* [Instrumenting our application](#how-to-send-logs-of-your-ecs-fargate-service-to-signoz)
* [Sending logs](#how-to-send-logs-of-your-ecs-fargate-service-to-signoz)
* [Deploying SigNoz on aws ecs](#to-deploy-signoz-on-aws-ecs)


### About SigNoz:

SigNoz provides comprehensive monitoring for your application. It tracks and monitors all the important metrics and logs related to your application, infrastructure, and network, and provides real-time alerts for any issues.

You can get traces,metrics and logs of your application.



![latency of api calls of a sample application](./images/latency-diagram.png "Title")
Latency of api calls to a sample application in signoz.

![traces of api calls of a sample application](./images/trace.png "Title")
Traces of our sample application in signoz.

![latency of api calls of a sample application](./images/logs.png "Title")
Logs of our sample application in signoz

![latency of api calls of a sample application](./images/cpu-metrics.png "Title")
CPU metrics of our sample application in signoz



Self hosting SigNoz on aws ecs fargate is also significantly cheaper than using aws native services like xray and cloudwatch to collect application metrics,traces and logs.SigNoz consists of a clikhouse cluster and multiple services, hosting them is tedious and inconvenient process but this template allows you to do so using a single command.

---
SigNoz architecture:

![signoz architecture](./images/signoz-architecture.png "Title")

We will be hosting our own clickhouse cluster using aws cloudformation and host all the services on aws ecs faragate.


---

### Pre-Requisites:

1. please have bash utility [jq](https://stedolan.github.io/jq/download/) installed to process json.
2. please have bash utility [yq](https://github.com/mikefarah/yq) installed to process yml. 
3. please install the [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [docker](https://docs.docker.com/engine/install/). 
4. Please have aws cli [To configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) with access key,secret and region. 
5. please have aws copilot version of the current develop branch on github. [To install - use make to install a standalone binary](https://github.com/aws/copilot-cli/blob/eda606604b61a4b00cdf0de4847784eb7a633b7d/CONTRIBUTING.md#environment)
6. please configure signoz-ecs-config.yml file with appropriate values.

---

### Config File:

The signoz-ecs-config.yml files containes all our configuration :

## Configuration
- ### application-name
  name of your aws copilot application, if you want to use an existing app please use the same app name
- ### environment-name
  environment name of your aws copilot application
- ### clickhouseConf:
  Config for the clickhouse cluster
  - #### stackName
    Name of the cloudformation stack which will create the clickhouse cluster
  - #### clickhouseDiskSize
    Disk size of the ec2 instance of the clickhouse in your clickhouse cluster
  - #### zookeeperDiskSize
    Disk size of the EC2 instance of the zookeeper in your clickhouse cluster
  - #### zookeeperInstanceType
    EC2 instance type to provision for Zookeeper
  - #### instanceType
    EC2 instance type to provision for the clickhosue shard
  - #### hostName
    Host of the clickhouse intance, please keep it black if you want to create your own clickhouse cluster, if your want to use an existing one please replace it with value of the host of one of your clickhouse shards
- ###  existingVpc:
  In case you already havee an existing VPC and would like to deploy your application in it, please  add in the required details below
  - #### vpcId
    Please fill the value if you want to use an existing vpc, if your want to create a new one please keep it empty
  - #### publicSubnetAId
    Subnet of the pre-existing public subnet, otherwise please leave it blank
  - #### publicSubnetBId
    Subnet of the pre-existing public subnet, otherwise please leave it blank
  - #### privateSubnetAId
    Subnet of the pre-existing private subnet, otherwise please leave it blank
  - #### privateSubnetBId
    Subnet of the pre-existing private subnet, otherwise please leave it blank
- #### fluentbitConf: 
  The config related to the custom fluentbit image we will be uploading to aws ecr
  - ####  repoName
    "fbit-repo" # name of the repo in aws ecr for the fluentbit image
  - #### localImageName
    "fbit" # name of the local fluentbit image we will be creating 
- ### otelSidecarConf: 
  The config related to the custom otel collector image we will be uploading to aws ecr
  - #### repoName
    name of the repo in aws ecr for the sidecar-otel image
  - #### localImageName
    name of the local sidecar-otel image we will be creating
- ### serviceNames
  name of the variouse SigNoz service we will be  deploying to aws ecs fargate
  - ####  otel
    name of the SigNoz otel collector service
  - ####  query
    name of the SigNoz query service
  - ####  alert
    name of the SigNoz alert service
  - ####  frontend
    name of the SigNoz frontend service

---

To instrument your applications and send data to SigNoz please refer- https://signoz.io/docs/instrumentation/

---


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
                                            

You can use custom ami's for zookeeper or clickhouse instances if your organization has special security needs or want to add more functionality (we have made our own [user-data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) scripts, so each clichouse shard and zookeeper can know about each other at start time). If you do not want to copy your ami's outside of a single region just replace the _ImageId_ field in clickhouse.yaml or clickhous-custom-vpc.yaml cloudformation template. If you want to copy ami's to all region then use *./scripts/copy-ami.sh* script and *./scripts/amimap.sh* to generate the mappings,then replace the existing mappings with the output.

---

### Why are we using aws copilot?

AWS Copilot CLI simplifies the deployment of your applications to AWS. It automates the process of creating AWS resources, configuring them, and deploying your application. This can save you time and effort compared to manual deployment.It simplifies the deployment of your applications to AWS. It automates the process of creating AWS resources, configuring them, and deploying your application. This can save you time and effort compared to manual deployment.
Aws copilot will allow us to deploy all our SigNoz services with minimum configuration

You are free to use your own custon vpc and subnets, though they should be the same as your clickhouse cluster(if hosting in a private subnet).
You will also have to configure vpc id,public and private subnets option in signoz-ecs-config.yml file

                                    signoz-app:
                                        public-subnet-a-id: ""
                                        public-subnet-b-id: ""
                                        private-subnet-a-id: ""
                                        private-subnet-b-id: ""
                                        vpc-id: ""



---

### How to instrument your aws ecs fargate service?

Please look at the following [documentation](https://signoz.io/docs/tutorials/) to add instrumentation to your application.
After you have added the code to your application, we will be abel to generate traces and metrics, and we will have to send this data to the SigNoz otel collector.
In our setup we will first configure an otel collector sidecar, which will then forward our data to the SigNoz otel collector, to do so we will add the following to our manifest file:
(please ensure you have uploaded the appropriate docker image for otel sidecar to aws ecr, you can get the image uri in output.yml file)

                                    sidecars:
                                        otel:
                                            port: 4317
                                            image: <AWS_ACCOUNT_ID>.dkr.ecr.ap-southeast-1.amazonaws.com/sidecar-otel:latest # uri of your sidecar otel image


We have configured an otel sidecar to forward our metrics and traces instead of directly sending them to SigNoz otel collector because, this will reduce the latency of our service whenever we are trying to connect to another database or service as we now have to talk to localhost instead of another ecs service.


To manuall upload the sidecar otel image use command:
```
    make otel-sidecar-upload
```



### How to send logs of your ecs fargate service to signoz?

To send logs of your application to SigNoz we are going to use [aws firelens](https://aws.amazon.com/about-aws/whats-new/2019/11/aws-launches-firelens-log-router-for-amazon-ecs-and-aws-fargate/).FireLens works with Fluentd and Fluent Bit. We provide the AWS for Fluent Bit image or you can use your own Fluentd or Fluent Bit image. We will create our own custom image where will configure rules which will forward logs from our application to the SigNoz collector using the fluentforward protocol.
When you deploy the template it will automatically deploy our custom fluentbit image to aws ecr and we have configured our SigNoz otel collector to accept logs via firelens.Using the command *make scaffold svcName* we can create a sample manifest file for you with firelens preconfigured. Configuring firelens using aws copilot is extremely easy, just add follwing to the mainfest file
```yaml
                                    logging:
                                        image: public.ecr.aws/k8o0c2l3/fbit:latest
                                        configFilePath: /logDestinations.conf
```
To manuall upload the fluenbit image use command:
```
    make fluentbit-upload
```

---


### Configuring values in signoz-ecs-config.yml

1. If your want to use an existing vpc please add the existing vpc block in the signoz-ecs-config.yml file.
2. If you want to use your own clickhouse cluster please mention the clickhouse host in the signoz-ecs-config.yml file(by default a new clickhouse cluster would be created).
3. If you want to host SigNoz  in an existing copilot application, just keep your application name and the enviroment same as the one you want to host SigNoz in.
4. You can change the name of cloudformation stack of your clickhouse cluster.
5. can change the instance type of your clikhouse or zookeeper hosts.
6. You can change the name of various SigNoz services in the config file.

### To deploy SigNoz on aws ecs:

(Please keep the value of clickhouse host blank if you want to deploy a new cluster in your vpc)


#### If you want to deploy from scratch - to deploy your own vpc,clickhouse cluster and fargate cluster

clone this repository locally then, configure signoz-ecs-config.yml with appropriate values(do not change the value of existing-vpc=no)

Then execute the script with 
```
make deploy
```

#### If you want to deploy clickhouse cluster and services in your own vpc:

clone this repository locally then, 
configure vpc id and subnet id in signoz-ecs-config.yml
make the value of variable existing-vpc to true
add the vpc id and all the subnets id

```
make deploy
```
#### If you have already deployed clickhouse cluster and want to deploy all services in a new vpc and fargate cluster:

clone this repository locally then, 
configure the clickhouse host in signoz-ecs-config.yml

```
make deploy
```

#### If you have already deployed clickhouse cluster and want to deploy all services in an existing vpc:

clone this repository locally then, 
configure the clickhouse host in signoz-ecs-config.yml
configure vpc id and subnet id in signoz-ecs-config.yml

```
make deploy
```

#### If you have already configured copilot with an app name and environment(the subnets should be the same as the one where clickhouse cluster is present):

clone this repository locally then, 
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
    

### For deleting all the services and cleaning up all the resources(is an irreversible action)

This will stop all the ecs services and your clickhouse cloudformation stack.

```
make delete
```
