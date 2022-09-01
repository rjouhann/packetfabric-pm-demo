# Cloud Service Provider initial setup

## Quick Start

1. Create the file ``secret.tfvars`` and update each variables.

```sh
cp secret.tfvars.sample secret.tfvars
```

2. Choose the CSP of your choice.

- AWS initial setup (create VPC, subnets, ec2, etc...):<br/>``cd aws_initial_setup``
- Azure initial setup (create VNet, subnets, VM, etc...):<br/>``cd azure_initial_setup``
- Google initial setup (create VPC, subnets, VM, etc...):<br/>``cd gcp_initial_setup``
- Oracle initial setup (create VNC, subnets, instance, etc...):<br/>``cd oracle_initial_setup``
- IBM initial setup (create VPC, subnets, instance, etc...):<br/>``cd ibm_initial_setup``

3. Create resources 
```sh
terraform init
terraform apply -auto-approve -var-file="../secret.tfvars"
```

4. Display values marked as sensitive (like Azure or Google service key)
```sh
terraform output service_key1
```

5. Cleanup/Remove all

```sh
terraform destroy -auto-approve -var-file="../secret.tfvars"
```