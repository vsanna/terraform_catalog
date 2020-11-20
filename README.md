## what is this
This repo is a catalog repository for terraform scripts, collection:
- modules
- examples
- patterns, etc..


## directories
```
.
├── README.md
├── examples              -- examples for how to use those modules
│         ├── acm
│         ├── alb
│         ├── ec2
│         ├── ecr
│         ├── ecs
│         ├── elasticache
│         ├── iamrole
│         ├── kms
│         ├── rds
│         ├── route53
│         ├── s3
│         ├── secretmanager
│         ├── securitygroup
│         ├── ssm
│         └── vpc
├── modules              -- modules for major components 
│         ├── acm
│         ├── alb
│         ├── cicd
│         ├── ec2
│         ├── ecr
│         ├── ecs
│         ├── elasticache
│         ├── iamrole
│         ├── kms
│         ├── network
│         ├── rds
│         ├── route53
│         ├── s3
│         ├── secretmanager
│         ├── securitygroup
│         ├── sessionmanager
│         └── ssm
├── recipes              -- real world scenarios using those modules 
│         ├── basic_network:     network + ec2(nginx) + bastion
│         ├── basic_datasource:  network + bastion + RDB + Redis 
│         └── advance_startup:   network + ALB + ECS + CodePipeline + RDB + Redis + S3. 
└── sandbox              -- playaround miscs
    ├── main.tf
    ├── null_resource
    ├── pet
    └── randoms
```