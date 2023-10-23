# Trabajo Practico Final Integrador

**Curso:** AWS Cloud Computing (999192849) \
**Alumno:** Flavio Lionel Rita

## Objetivo

El objetivo de este trabajo es levantar una infraestructura en AWS que permita ejecutar un laboratorio de [λORM](https://www.npmjs.com/package/lambdaorm) en un cluster de contenedores. \
Con el fin de:

- Mostrar el servicio de [λORM](https://www.npmjs.com/package/lambdaorm)  a terceros
- Hacer pruebas de performance

Como esto es un laboratorio para ser mostrado temporalmente, se precisa poder levantar y bajar la infraestructura de forma automatizada. \
Por este motivo se utilizara CloudFormation para levantar la infraestructura. \
Se crearan tareas de automatización para ejecutar scripts para inicializar la base de datos y copiar el schema de [λORM](https://www.npmjs.com/package/lambdaorm) desde un bucket de S3 al volumen del contenedor en EFS.

### [λORM](https://www.npmjs.com/package/lambdaorm)

Es un ORM escrito en Node.js que basa sus consultas en un modelo de dominio, abstrayéndose del modelo físico. \
Mediante reglas se determina la Fuente de Datos correspondiente y mediante definición de mapeo se define cómo se mapea el modelo de dominio con el físico.

Lo que diferencia a λORM de otros ORM:

- Obtener o modificar registros de diferentes Bases de Datos en una misma consulta.
  Estas Bases de Datos pueden ser de diferentes motores (Ejemplo: MySQL, PostgreSQL, MongoDB, etc.)

- Abstracción del modelo físico, siendo lo mismo trabajar con una única base de datos que con varias.

- Definir diferentes stages para un modelo de dominio.
  Puedes definir un stage donde trabajes con una instancia de MySQL y otro stage donde trabajes con Oracle y MongoDB.

- Sintaxis de consulta amigable, pudiendo escribir en el propio lenguaje de programación como en una cadena.
  Las expresiones se analizan de la misma manera que con un lenguaje de expresión.

- Puede ser consumido de diferentes maneras:
  - Como un paquete de Node.js
  - Como un servicio REST
  - Como CLI
  - Como un Cliente de Servicio REST en Node.js
  - Como un Cliente de Servicio REST en Kotlin

## Solución

### Arquitectura

### Servicios

| Servicio                                  | Descripción                                                                                                                   |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| AWS CloudFormation                        | Servicio que le ayuda a modelar y configurar sus recursos de AWS de forma segura, eficiente y repetible.                      |
| Amazon Virtual Private Cloud (VPC)        | Servicio que le permite aprovisionar una sección de la nube de AWS aislada lógicamente donde puede ejecutar recursos de AWS.  |
| Amazon Elastic Container Service (ECS)    | Servicio de orquestación de contenedores altamente escalable y de alto rendimiento que admite contenedores de Docker          |
| Amazon Elastic Compute Cloud (EC2)        | Servicio web que proporciona capacidad informática segura y de tamaño modificable en la nube.                                 |
| Amazon Identity and Access Management     | Proporciona seguridad para controlar el acceso y los privilegios de los usuarios a los recursos de AWS.                       |
| Amazon Elastic File System (EFS)          | Proporciona un almacenamiento de archivos sencillo, escalable y elástico para casos de uso de Linux para la nube.             |
| Amazon Relational Database Service (RDS)  | Facilita la configuración, el funcionamiento y el escalado de las bases de datos relacionales en la nube.                     |
| Amazon Simple Storage Service (S3)        | Servicio de almacenamiento de objetos que ofrece escalabilidad, disponibilidad de datos, seguridad y rendimiento              |
| Amazon CloudWatch                         | Servicio de supervisión y observación integral para recursos en la nube y aplicaciones en ejecución en AWS.                   |
| Amazon CloudWatch Logs                    | Servicio para monitorear y diagnosticar aplicaciones y sistemas en tiempo real.                                               |
| Amazon Lambda                             | Servicio informático sin servidor que le permite ejecutar código sin aprovisionar ni administrar servidores.                  |
| Amazon Load Balancer (ALB)                | Distribuye el tráfico de entrada a varias aplicaciones o contenedores en función de las reglas de enrutamiento                |

## Costos

| Servicio                                  | Costo Diario              | Costo Mensual                 | Detalle del Calculo                                   |
| ----------------------------------------- | ------------------------- | ----------------------------- | ----------------------------------------------------- |
| AWS CloudFormation                        | $0.00                     | $0.00                         |                                                       |
| Amazon Virtual Private Cloud (VPC)        | $0.00                     | $0.00                         |                                                       |
| Amazon Elastic Container Service (ECS)    | $0.00                     | $0.00                         |                                                       |
| Amazon Elastic Compute Cloud (EC2)        | $0.00                     | $0.00                         |                                                       |
| Amazon Identity and Access Management     | $0.00                     | $0.00                         |                                                       |
| Amazon Elastic File System (EFS)          | $0.00                     | $0.00                         |                                                       |
| Amazon Relational Database Service (RDS)  | $0.00                     | $0.00                         |                                                       |
| Amazon Simple Storage Service (S3)        | $0.00                     | $0.00                         |                                                       |
| Amazon CloudWatch                         | $0.00                     | $0.00                         |                                                       |
| Amazon CloudWatch Logs                    | $0.00                     | $0.00                         |                                                       |
| Amazon Lambda                             | $0.00                     | $0.00                         |                                                       |
| Amazon Load Balancer (ALB)                | $0.00                     | $0.00                         |                                                       |
| **Total**                                 | **$0.00**                 | **$0.00**                     |                                                       |

## Implementación

### Configuración Inicial

- Zona: eu-west-1 (Ireland)
- KeyName: SSH

### Network

- VPC con un Internet gateway.
- Dos conjuntos de una subred pública y una subred privada. Cada conjunto debe pertenecer a diferentes zonas de disponibilidad.
  - La subred pública debe enrutar el tráfico de Internet a través del gateway de Internet de VPC.
  - La subred pública debe tener una puerta de enlace NAT adjunta.
  - La subred privada debe enrutar el tráfico de Internet a través de la puerta de enlace NAT adjunta en la subred pública.

**Resources Created:**

### Security Groups

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./securityGroups/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./securityGroups/.env) --stack-name lambdaorm-security-groups
```

**Resources Created:**

| Logical Resource Id                       | Resource Type                           |
| ----------------------------------------- | --------------------------------------- |

### Database

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./database/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./database/.env) --stack-name lambdaorm-database
```

**Resources Created:**

| Logical Resource Id                       | Resource Type                           |
| ----------------------------------------- | --------------------------------------- |

### Load Balancer

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./loadBalancer/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./loadBalancer/.env) --stack-name lambdaorm-load-balancer
```

**Resources Created:**

| Logical Resource Id                       | Resource Type                           |
| ----------------------------------------- | --------------------------------------- |

### Storage

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./storage/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./storage/.env) --stack-name lambdaorm-storage
```

**Resources Created:**

| Logical Resource Id                       | Resource Type                           |
| ----------------------------------------- | --------------------------------------- |

### Cluster

- Se implementa un Cluster con contenedores de LambdaOrm en AWS Elastic Container Service (ECS).
- Estos contenedores se conectan a:
  - Elastic File System (EFS) para acceder al archivo de esquema de lambdaOrm
  - Base de datos relacional (RDS) para almacenar los datos.
- Requisitos:
  - VPC con una puerta de enlace a Internet.
  - Dos conjuntos de una subred privada y una subred pública que pertenece a diferentes zonas de disponibilidad.
  - Cada subred pública debe tener una puerta de enlace NAT adjunta y la subred privada
    en la zona de disponibilidad respectiva deben enrutar el tráfico de Internet a través de esa Puerta de enlace NAT.
- Parámetros: se pasaran a traves de un archivo de variables de ambiente

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./cluster/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./cluster/.env) --stack-name lambdaorm-cluster
```

**Create Cluster:**

```sh
aws cloudformation deploy --template-file ./cluster/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./cluster/.env) --stack-name lambdaorm-cluster
```

**Resources Created:**

| Logical Resource Id                       | Resource Type                           |
| ----------------------------------------- | --------------------------------------- |

### Service

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./service/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./service/.env) --stack-name lambdaorm-service
```

**Resources Created:**

| Logical Resource Id                       | Resource Type                           |
| ----------------------------------------- | --------------------------------------- |

### EC2

**Create:**

```sh
aws cloudformation deploy --region eu-west-1 --template-file ./ec2/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./ec2/.env) --stack-name lambdaorm-ec2
```

**Resources Created:**

| Logical Resource Id                       | Resource Type                           |
| ----------------------------------------- | --------------------------------------- |

### Script de creación

```sh
# Network
cat <<EOF > ./network/.env
Namespace=lambdaorm
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
DBUsername=northwind
DBPassword=northwind
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
DBUsername=northwind
DBPassword=northwind
EOF
aws cloudformation deploy --template-file ./service/template.yaml --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND --parameter-overrides $(cat ./service/.env) --stack-name lambdaorm-service  &&
aws cloudformation describe-stacks --region eu-west-1 --query "Stacks[?StackName=='lambdaorm-service'][].Outputs" --no-paginate --output json > ./service/result.json &&
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
```

### Script de borrado

```sh
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-ec2 && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-ec2 &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-service && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-service &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-cluster && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-cluster &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-storage && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-storage &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-load-balancer && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-load-balancer &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-database && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-database &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-security-groups && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-security-groups &&
aws cloudformation delete-stack --region eu-west-1 --stack-name lambdaorm-network && aws cloudformation wait stack-delete-complete --stack-name lambdaorm-network
```

## Inicializar base de datos

**copy and execute sql initialization:**

```sh
chmod 400 ./ec2/SSH.pem
scp -i ./ec2/SSH.pem ../workspace/northwind-mysql.sql ec2-user@ec2-54-170-226-72.eu-west-1.compute.amazonaws.com:/home/ec2-user
scp -i ./ec2/SSH.pem ../workspace/lambdaORM.yaml ec2-user@ec2-54-170-226-72.eu-west-1.compute.amazonaws.com:/home/ec2-user
ssh -i ./ec2/SSH.pem ec2-user@ec2-54-170-226-72.eu-west-1.compute.amazonaws.com
sudo mv ./lambdaORM.yaml /mnt/efs/workspace/lambdaORM.yaml
mysql -h lambdaorm-mysql.cqmjptrynsxv.eu-west-1.rds.amazonaws.com -u northwind -pnorthwind northwind < northwind-mysql.sql
exit
# verify
# mysql -h lambdaorm-mysql.cqmjptrynsxv.eu-west-1.rds.amazonaws.com -u northwind -pnorthwind northwind
# use northwind;
# show tables;
# select count(1) from Orders;
# exit


**Conectarse a la instancia EC2:**

```bash
chmod 400 ./ec2/SSH.pem
## connect to EC2 instance
ssh -i ./ec2/SSH.pem ec2-user@ec2-34-244-253-27.eu-west-1.compute.amazonaws.com -y
## install mysql client
sudo yum install mysql -y
## connect to RDS instance from EC2 instance
mysql -u northwind -pnorthwind -h lambdaorm-mysql.cqmjptrynsxv.eu-west-1.rds.amazonaws.com

```

**Asociar EFS a EC2:**

```sh
sudo yum install -y amazon-efs-utils
sudo mkdir /mnt/efs
sudo mount -t efs -o tls fs-0503cb0ec5bf19d9c:/ /mnt/efs
#verify
df -h
cd /mnt/efs
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

## Pendientes

### Automatización de Tareas

- Crear lambda que se ejecute cuando se suba un schema a un bucket de S3 especifico y lo copie al EFS.
- Crear lambda que se ejecute cuando se suba un script de SQL a un bucket de S3 especifico y lo ejecute en la base de datos.

## References

- AWS
  - EC2
    - [Create key pairs](https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#KeyPairs:)
    - [Install MySql Client](https://muleif.medium.com/how-to-install-mysql-on-amazon-linux-2023-5d39afa5bf11)
  - Cluster  
    - [ECS example](https://github.com/jquirossoto/wordpress-multisite-ecs-efs-rds/blob/master/README.md)
- λORM
  - [npm](https://www.npmjs.com/package/lambdaorm)
  - [Github](https://github.com/FlavioLionelRita/lambdaorm)
