# CloudFormation templates for lambdaORM

## Configuración Inicial

- Zona: eu-west-1 (Ireland)
- Create Key Pair: SSH

## Create for script

```sh
./create.sh
```

## Create for steps

### Network

**Create environment file:**

```sh
cat <<EOF > ./network/.env
Namespace=lambdaorm
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./network/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND  --parameter-overrides $(cat ./network/.env) --stack-name lambdaorm-network
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-network'][].Outputs" --no-paginate --output json > ./network/result.json
```

### Security Groups

**Create environment file:**

```sh
cat <<EOF > ./securityGroups/.env
Namespace=lambdaorm
VpcId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
PublicSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PublicSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PublicSubnet2") | .OutputValue'  ./network/result.json)
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./securityGroups/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./securityGroups/.env) --stack-name lambdaorm-security-groups
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-security-groups'][].Outputs" --no-paginate --output json > ./securityGroups/result.json
```

### Database

**Create environment file:**

```sh
cat <<EOF > ./database/.env
Namespace=lambdaorm
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
DatabaseSecurityGroup=$(jq -r '.[][] | select(.OutputKey=="DatabaseSecurityGroup") | .OutputValue'  ./securityGroups/result.json)
DBUsername=northwind
DBPassword=northwind
DatabaseInstanceClass=db.t3.micro
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./database/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./database/.env) --stack-name lambdaorm-database
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-database'][].Outputs" --no-paginate --output json > ./database/result.json
```

### Load Balancer

**Create environment file:**

```sh
cat <<EOF > ./loadBalancer/.env
Namespace=lambdaorm
VPCId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
PublicSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PublicSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PublicSubnet2") | .OutputValue'  ./network/result.json)
LoadBalancerSecurityGroup=$(jq -r '.[][] | select(.OutputKey=="LoadBalancerSecurityGroup") | .OutputValue'  ./securityGroups/result.json)
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./loadBalancer/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./loadBalancer/.env) --stack-name lambdaorm-load-balancer
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-load-balancer'][].Outputs" --no-paginate --output json > ./loadBalancer/result.json
```

### Storage

**Create environment file:**

```sh
cat <<EOF > ./storage/.env
Namespace=lambdaorm
VpcId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
ServiceSecurityGroup=$(jq -r '.[][] | select(.OutputKey=="ServiceSecurityGroup") | .OutputValue'  ./securityGroups/result.json)
EC2SecurityGroup=$(jq -r '.[][] | select(.OutputKey=="EC2SecurityGroup") | .OutputValue'  ./securityGroups/result.json)
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./storage/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./storage/.env) --stack-name lambdaorm-storage
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-storage'][].Outputs" --no-paginate --output json > ./storage/result.json
```

### cluster

**Create environment file:**

```sh
cat <<EOF > ./cluster/.env
Namespace=lambdaorm
VpcId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
SubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./cluster/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./cluster/.env) --stack-name lambdaorm-cluster
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-cluster'][].Outputs" --no-paginate --output json > ./cluster/result.json
```

### Service

**Create environment file:**

```sh
cat <<EOF > ./service/.env
Namespace=lambdaorm
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
Cluster=$(jq -r '.[][] | select(.OutputKey=="ECSCluster") | .OutputValue'  ./cluster/result.json)
ServiceSecurityGroup=$(jq -r '.[][] | select(.OutputKey=="ServiceSecurityGroup") | .OutputValue'  ./securityGroups/result.json)
LoadBalancerUrl=$(jq -r '.[][] | select(.OutputKey=="LoadBalancerUrl") | .OutputValue'  ./loadBalancer/result.json)
LoadBalancerTargetGroup=$(jq -r '.[][] | select(.OutputKey=="LoadBalancerTargetGroup") | .OutputValue'  ./loadBalancer/result.json)
EFSAccessPoint=$(jq -r '.[][] | select(.OutputKey=="EFSAccessPoint") | .OutputValue'  ./storage/result.json)
EFSFileSystem=$(jq -r '.[][] | select(.OutputKey=="EFSFileSystem") | .OutputValue'  ./storage/result.json)
ECSLogGroup=$(jq -r '.[][] | select(.OutputKey=="ECSLogGroup") | .OutputValue'  ./cluster/result.json)
DatabaseEndpointAddress=$(jq -r '.[][] | select(.OutputKey=="DatabaseEndpointAddress") | .OutputValue'  ./database/result.json)
DBUsername=northwind
DBPassword=northwind
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./service/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./service/.env) --stack-name lambdaorm-service
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-service'][].Outputs" --no-paginate --output json > ./service/result.json
```

### Wordpress

- host: [http://wordpress-ecs-LB-1719308356.eu-west-1.elb.amazonaws.com]
- username: manager
- password: LvJS2@ABE%lamDs2Hc
- email: [flaviolrita@proton.me]

### EC2

**Create environment file:**

```sh
cat <<EOF > ./ec2/.env
Namespace=lambdaorm
EC2SecurityGroup=$(jq -r '.[][] | select(.OutputKey=="EC2SecurityGroup") | .OutputValue'  ./securityGroups/result.json)
PublicSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PublicSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PublicSubnet2") | .OutputValue'  ./network/result.json)
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
KeyName=SSH
EFSAccessPoint=$(jq -r '.[][] | select(.OutputKey=="EFSAccessPoint") | .OutputValue'  ./storage/result.json)
EFSFileSystem=$(jq -r '.[][] | select(.OutputKey=="EFSFileSystem") | .OutputValue'  ./storage/result.json)
EOF
```

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./ec2/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./ec2/.env) --stack-name lambdaorm-ec2
```

**Get outputs:**

```sh
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-ec2'][].Outputs" --no-paginate --output json > ./ec2/result.json
```

### Inicializar base de datos

**Conectarse a la instancia EC2:**

```bash
chmod 400 SSH.pem
## connect to EC2 instance
ssh -i "SSH.pem" ec2-user@ec2-34-247-92-153.eu-west-1.compute.amazonaws.com
## connect to RDS instance from EC2 instance
sudo yum install mysql -y
mysql -u northwind -p -h db-instance.cqmjptrynsxv.eu-west-1.rds.amazonaws.com
northwind
```

**Create northwind database:**

```sql
CREATE USER IF NOT EXISTS 'northwind'@'%' IDENTIFIED BY 'northwind';
CREATE DATABASE IF NOT EXISTS northwind;
GRANT ALL PRIVILEGES on northwind.* To northwind@'%';
FLUSH PRIVILEGES;
SHOW databases;
exit;
```

**Verify connection to northwind:**

```sh
mysql -u northwind -p -h db-instance.cqmjptrynsxv.eu-west-1.rds.amazonaws.com
northwind
SHOW databases;
exit;
```

**copy and execute sql initialization:**

```sh
scp -i ./ec2/SSH.pem ./workspace/northwind-mysql.sql ec2-user@ec2-34-247-92-153.eu-west-1.compute.amazonaws.com:/home/ec2-user
ssh -i ./ec2/SSH.pem ec2-user@ec2-34-247-92-153.eu-west-1.compute.amazonaws.com
mysql -h db-instance.cqmjptrynsxv.eu-west-1.rds.amazonaws.com -u northwind -p northwind < northwind-mysql.sql
northwind
# verify
mysql -u northwind -p -h db-instance.cqmjptrynsxv.eu-west-1.rds.amazonaws.com
northwind
use northwind;
show tables;
select count(1) from Orders;
exit;
```

## Remove for script

```sh
./remove.sh
```

## Remove for steps

```sh
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-ec2 && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-ec2
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-service && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-service
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-cluster && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-cluster
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-storage && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-storage
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-load-balancer && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-load-balancer
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-database && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-database
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-security-groups && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-security-groups
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-network && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-network
```

## References

- ECS:
  - [example](https://github.com/jquirossoto/wordpress-multisite-ecs-efs-rds/blob/master/README.md)
  - [fargate example](https://github.com/1Strategy/fargate-cloudformation-example/blob/master/fargate.yaml)
- Create Cluster with EC2 instances:
  - [YouTube crea un cluster por consola web](https://www.youtube.com/watch?v=2LXeOACB1NM)
  - [Cluster with EC2 Capacity Provider](https://containersonaws.com/pattern/ecs-ec2-capacity-provider-scaling)
  - [ECS cluster](https://templates.cloudonaut.io/en/stable/ecs/#ecs-cluster-cost-optimzed)
  - [Example](https://raw.githubusercontent.com/aws-observability/aws-otel-collector/main/deployment-template/ecs/aws-otel-ec2-sidecar-deployment-cfn.yaml)
  - [ECS EC2 Cloudformation Template](https://aws-otel.github.io/docs/setup/ecs/cfn-for-ecs-ec2)
  - [Managing compute for Amazon ECS clusters with capacity providers](https://aws.amazon.com/blogs/containers/managing-compute-for-amazon-ecs-clusters-with-capacity-providers/)
  - [Deploying to AWS ECS Using Cloudformation and Spot Instances](https://www.jasonneurohr.com/articles/deploying-to-aws-ecs-using-cloudformation-and-spot-instances/)
- Mount EFS on EC2
  - [Attach EFS en instancia EC2](https://www.youtube.com/watch?v=V9WE1aKuBp0)
