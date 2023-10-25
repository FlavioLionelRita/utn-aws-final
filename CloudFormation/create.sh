Namespace=lambdaorm
DBUsername=northwind
DBPassword=northwind
# Network
cat <<EOF > ./network/.env
Namespace=${Namespace}
EOF
aws cloudformation deploy --region eu-west-1 --template-file ./network/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND  --parameter-overrides $(cat ./network/.env) --stack-name lambdaorm-network &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-network'][].Outputs" --no-paginate --output json > ./network/result.json &&
# Security Groups
cat <<EOF > ./securityGroups/.env
Namespace=lambdaorm
VpcId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
PublicSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PublicSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PublicSubnet2") | .OutputValue'  ./network/result.json)
EOF
aws cloudformation deploy --template-file ./securityGroups/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./securityGroups/.env) --stack-name lambdaorm-security-groups &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-security-groups'][].Outputs" --no-paginate --output json > ./securityGroups/result.json  &&
# Database
cat <<EOF > ./database/.env
Namespace=lambdaorm
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
DatabaseSecurityGroup=$(jq -r '.[][] | select(.OutputKey=="DatabaseSecurityGroup") | .OutputValue'  ./securityGroups/result.json)
DBUsername=${DBUsername}
DBPassword=${DBPassword}
DatabaseInstanceClass=db.t3.micro
EOF
aws cloudformation deploy --template-file ./database/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./database/.env) --stack-name lambdaorm-database  &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-database'][].Outputs" --no-paginate --output json > ./database/result.json  &&
# Load Balancer
cat <<EOF > ./loadBalancer/.env
Namespace=lambdaorm
VPCId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
PublicSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PublicSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PublicSubnet2") | .OutputValue'  ./network/result.json)
LoadBalancerSecurityGroup=$(jq -r '.[][] | select(.OutputKey=="LoadBalancerSecurityGroup") | .OutputValue'  ./securityGroups/result.json)
EOF
aws cloudformation deploy --template-file ./loadBalancer/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./loadBalancer/.env) --stack-name lambdaorm-load-balancer  &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-load-balancer'][].Outputs" --no-paginate --output json > ./loadBalancer/result.json  &&
# Storage
cat <<EOF > ./storage/.env
Namespace=lambdaorm
VpcId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
ServiceSecurityGroup=$(jq -r '.[][] | select(.OutputKey=="ServiceSecurityGroup") | .OutputValue'  ./securityGroups/result.json)
EC2SecurityGroup=$(jq -r '.[][] | select(.OutputKey=="EC2SecurityGroup") | .OutputValue'  ./securityGroups/result.json)
EOF
aws cloudformation deploy --template-file ./storage/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./storage/.env) --stack-name lambdaorm-storage  &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-storage'][].Outputs" --no-paginate --output json > ./storage/result.json  &&
# Cluster
cat <<EOF > ./cluster/.env
Namespace=lambdaorm
VpcId=$(jq -r '.[][] | select(.OutputKey=="VpcId") | .OutputValue'  ./network/result.json)
SubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
EOF
aws cloudformation deploy --region eu-west-1 --template-file ./cluster/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./cluster/.env) --stack-name lambdaorm-cluster &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-cluster'][].Outputs" --no-paginate --output json > ./cluster/result.json  &&
# EC2
cat <<EOF > ./ec2/.env
Namespace=lambdaorm
EC2SecurityGroup=$(jq -r '.[][] | select(.OutputKey=="EC2SecurityGroup") | .OutputValue'  ./securityGroups/result.json)
PublicSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PublicSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PublicSubnet2") | .OutputValue'  ./network/result.json)
PrivateSubnetIds=$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet1") | .OutputValue'  ./network/result.json),$(jq -r '.[][] | select(.OutputKey=="PrivateSubnet2") | .OutputValue'  ./network/result.json)
KeyName=SSH
EFSAccessPoint=$(jq -r '.[][] | select(.OutputKey=="EFSAccessPoint") | .OutputValue'  ./storage/result.json)
EFSFileSystem=$(jq -r '.[][] | select(.OutputKey=="EFSFileSystem") | .OutputValue'  ./storage/result.json)
EOF
aws cloudformation deploy --region eu-west-1 --template-file ./ec2/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./ec2/.env) --stack-name lambdaorm-ec2 &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-ec2'][].Outputs" --no-paginate --output json > ./ec2/result.json
# Initialize Database and copy lambdaORM.yaml
EC2PublicDnsName=$(jq -r '.[][] | select(.OutputKey=="EC2PublicDnsName") | .OutputValue'  ./ec2/result.json)
DatabaseEndpointAddress=$(jq -r '.[][] | select(.OutputKey=="DatabaseEndpointAddress") | .OutputValue'  ./database/result.json)
chmod 400 ./ec2/SSH.pem
scp -i ./ec2/SSH.pem ../workspace/northwind-mysql.sql ec2-user@${EC2PublicDnsName}:/home/ec2-user
scp -i ./ec2/SSH.pem ../workspace/lambdaORM.yaml ec2-user@${EC2PublicDnsName}:/home/ec2-user
ssh -i ./ec2/SSH.pem ec2-user@${EC2PublicDnsName}
mysql -h ${DatabaseEndpointAddress} -u ${DBUsername} -p${DBPassword} northwind < northwind-mysql.sqlc
# mysql -h lambdaorm-mysql.cqmjptrynsxv.eu-west-1.rds.amazonaws.com -u northwind -pnorthwind northwind < northwind-mysql.sql
exit
# Service
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
DBUsername=${DBUsername}
DBPassword=${DBPassword}
EOF
aws cloudformation deploy --template-file ./service/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./service/.env) --stack-name lambdaorm-service  &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-service'][].Outputs" --no-paginate --output json > ./service/result.json

