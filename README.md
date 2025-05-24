# alt-devops-task
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

    VPC CIDR: 10.10.20.0/16

        3 public subnets → /24 (3×256 IPs)

        3 private subnets → /20 (3×4096 IPs)

        3 database subnets → /24 (3×256 IPs)

The entire solution must be implemented as code using Terraform.

Reference Solution(Diagram 2):
![image](https://github.com/user-attachments/assets/44a74a5a-0733-4849-9426-550f0193f920)


## Business Drivers
Are currently unknown, but we definitely operate in the sales domain and offer some kind of payment solution :)


## Terraform code

Please ignore `tfe_oidc` and `workspaces` folders it is a refined accelerator from another repo to run everything in TFE.

#### Workspaces:

- level1 - network infra 
- level2 - compute infra and db(for simplicity)
