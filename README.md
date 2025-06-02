# alt-devops-task

[![Checkov PCI DSS Compliance Scan](https://github.com/my-tf-lab/alt-devops-task/actions/workflows/checkov-dss.yaml/badge.svg)](https://github.com/my-tf-lab/alt-devops-task/actions/workflows/checkov-dss.yaml)

Devops Task 00000010


## Context
There is an environment that was created manually, which needs to undergo a PCI DSS audit.
An approximate diagram of the original environment is shown in Diagram 1:


![image](https://github.com/user-attachments/assets/f264824e-4034-490d-ba83-2329f27e0fca)


A solution must be proposed that complies with PCI DSS requirements 1.3.1 and 1.3.2.

To meet these requirements, I propose using a classic Three-tier Architecture:
public subnets for the DMZ, private subnets for application execution, and separate subnets for databases.


For the database engine, I recommend using Amazon RDS, as it is a more reliable managed service and increases the likelihood of passing the audit.

For the network design, we need to plan the IP address space in advance. Taking into account the current configuration and potential growth, I have chosen the following address allocation:

    VPC CIDR: 10.10.0.0/16

        3 public subnets → /24 (3×256 IPs)

        3 private subnets → /20 (3×4096 IPs)

        3 database subnets → /24 (3×256 IPs)

        3 firewall subnets → /28 (3×16 IPs)

Application will be accessed behind ALB chain: Public ALB pointing to Internal ALB. Outgress will be controlled by AWS Network Firewall and NAT GW.

The entire solution must be implemented as code using Terraform.

Reference Solution(Diagram 2):
![image](https://github.com/user-attachments/assets/3abc1b0c-8318-4ede-96b3-b469c61172a5)


### Reference network security(subject to change)
 
#### Network ACL Rules

##### Public NACL

| Rule Type | Protocol | Port(s)       | CIDR            | Description                         |
|-----------|----------|---------------|------------------|-------------------------------------|
| Inbound   | TCP      | 80            | 0.0.0.0/0        | Allow HTTP                          |
| Inbound   | TCP      | 443           | 0.0.0.0/0        | Allow HTTPS                         |
| Inbound   | TCP      | 22            | Home IP / VPC    | Allow SSH from home/VPC            |
| Inbound   | TCP      | 1024-65535    | VPC CIDR         | Allow Ephemeral from VPC           |
| Inbound   | UDP/TCP  | 53            | 0.0.0.0/0        | Allow DNS                          |
| Outbound  | TCP      | 80            | VPC CIDR         | Allow HTTP to internal             |
| Outbound  | TCP      | 22            | 0.0.0.0/0        | Allow SSH outbound                 |
| Outbound  | TCP      | 1024-65535    | 0.0.0.0/0        | Allow Ephemeral                    |

##### Private NACL

| Rule Type | Protocol | Port(s)       | CIDR         | Description                          |
|-----------|----------|---------------|--------------|--------------------------------------|
| Inbound   | TCP      | 3306          | VPC CIDR     | Allow MySQL                          |
| Inbound   | TCP      | 22            | VPC CIDR     | Allow SSH                            |
| Inbound   | TCP      | 80            | 0.0.0.0/0    | Allow HTTP                           |
| Inbound   | TCP      | 443           | VPC CIDR     | Allow HTTPS                          |
| Inbound   | UDP/TCP  | 53            | 0.0.0.0/0    | Allow DNS                            |
| Outbound  | TCP      | 22            | VPC CIDR     | Allow SSH                            |
| Outbound  | TCP      | 1024-65535    | 0.0.0.0/0    | Allow Ephemeral                      |

---

### Security Groups

##### `app` Security Group

| Direction | Protocol | Port(s)     | Source                   | Description                        |
|-----------|----------|-------------|---------------------------|------------------------------------|
| Ingress   | TCP      | 80-443      | Internal ALB SG           | Allow HTTP/HTTPS from ALB         |
| Ingress   | TCP      | 22          | Bastion SG                | Allow SSH from Bastion            |
| Ingress   | TCP      | 1024-65535  | VPC CIDR                  | Allow Ephemeral                    |
| Egress    | ALL      | ALL         | VPC CIDR                  | Allow all outbound traffic        |

##### `rds` Security Group

| Direction | Protocol | Port(s) | Source       | Description                 |
|-----------|----------|---------|--------------|-----------------------------|
| Ingress   | TCP      | 3306    | App SG       | Allow MySQL from App       |
| Egress    | ALL      | ALL     | VPC CIDR     | Allow all outbound         |

##### `internal_alb` Security Group

| Direction | Protocol | Port(s) | Source         | Description                  |
|-----------|----------|---------|----------------|------------------------------|
| Ingress   | TCP      | 80-443  | Public NLB SG  | Allow HTTP/HTTPS from Public|
| Egress    | TCP      | 80-443  | App SG         | Allow HTTP/HTTPS to App     |

##### `public_nlb` Security Group

| Direction | Protocol | Port(s) | Source     | Description                |
|-----------|----------|---------|------------|----------------------------|
| Ingress   | TCP      | 80-443  | 0.0.0.0/0  | Allow HTTP/HTTPS from all |
| Egress    | TCP      | 80-443  | Internal ALB SG | Allow traffic to internal ALB |



## Business Drivers
Are currently unknown, but we definitely operate in the sales domain and offer some kind of payment solution :)


## Terraform code

Please ignore `tfe_oidc` and `workspaces` folders it is a refined accelerator from another repo to run everything in TFE.

#### Workspaces:

- level1 - Network infra. AWS Firewall and NAT GW controlled by flags to decrease costs.
- level2 - Compute infra and db(for simplicity)


## Testing 

I tested network copnnectivity for app and bastion instances to proove that solution works.

1. Test that bastion host provide access to instances in private subnets.
I used proxy jump to simplify test
```
Host app-node
  HostName 10.10.102.119
  User ec2-user
  IdentityFile ~/sshkeys/phab_key
  ProxyJump ec2-user@34.204.92.166
```
and the output was as expected:
```
ssh app-node
   ,     #_
   ~\_  ####_
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   Amazon Linux 2023 (ECS Optimized)
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'

For documentation, visit http://aws.amazon.com/documentation/ecs
Last login: Mon May 26 22:46:49 2025 from 10.10.2.13
```
2. Test that application running on private network accessable via Public DNS name of NLB: public-nlb-77c14a074697a95d.elb.us-east-1.amazonaws.com

For testing purposes i use simple python http server on port 80: https://github.com/my-tf-lab/alt-devops-task/blob/a2190027d1428c604ad60e3d0800b06b108485b8/level2/ec2.tf#L37

```
 (main) ∙> curl -vvv  public-nlb-77c14a074697a95d.elb.us-east-1.amazonaws.com
02:29:44.854088 [0-x] == Info: [READ] client_reset, clear readers
02:29:44.884231 [0-0] == Info: Host public-nlb-77c14a074697a95d.elb.us-east-1.amazonaws.com:80 was resolved.
02:29:44.884373 [0-0] == Info: IPv6: (none)
02:29:44.884429 [0-0] == Info: IPv4: 13.216.18.134
02:29:44.884491 [0-0] == Info: [SETUP] added
02:29:44.884561 [0-0] == Info:   Trying 13.216.18.134:80...
02:29:45.051124 [0-0] == Info: Connected to public-nlb-77c14a074697a95d.elb.us-east-1.amazonaws.com (13.216.18.134) port 80
02:29:45.051620 [0-0] == Info: using HTTP/1.x
02:29:45.051865 [0-0] => Send header, 119 bytes (0x77)
0000: GET / HTTP/1.1
0010: Host: public-nlb-77c14a074697a95d.elb.us-east-1.amazonaws.com
004f: User-Agent: curl/8.11.1
0068: Accept: */*
0075: 
02:29:45.052639 [0-0] == Info: Request completely sent off
02:29:45.163634 [0-0] <= Recv header, 17 bytes (0x11)
0000: HTTP/1.1 200 OK


...

02:29:45.172786 [0-0] == Info: [READ] client_reset, clear readers
02:29:45.172830 [0-0] == Info: Connection #0 to host public-nlb-77c14a074697a95d.elb.us-east-1.amazonaws.com left intact
```
Its alive!

3. Test that secureweb.com is avalible from private network:



PS. Before run local states like `tf-oidc, workspaces` you need to define several env variables:

```
export TF_VAR_tfe_aws_role="arn:aws:iam::xxxxxxx:role/terraform-cloud-oidc-access-deployment-role"
export TF_VAR_hcp_client_id=""
export TF_VAR_hcp_client_secret=""
export TF_VAR_tfe_token=""
export TF_VAR_oauth_token_id=""
export TF_VAR_rds_username=""
export TF_VAR_rds_password=""
```
