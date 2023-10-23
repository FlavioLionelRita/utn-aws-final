aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-service && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-service &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-ec2 && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-ec2 &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-cluster && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-cluster &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-storage && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-storage &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-load-balancer && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-load-balancer &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-database && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-database &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-security-groups && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-security-groups &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-network && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-network