# Cloud Service Provider Others

## Quick Start

1. Create the file ``secret.tfvars`` and update each variables.

```sh
cp secret.tfvars.sample secret.tfvars
```

2. Choose the folder of your choice.

- AWS Direct Connect Peering:<br/>``cd aws_peering_connections``

3. Create resources 
```sh
terraform init
terraform apply -auto-approve -var-file="../secret.tfvars"
```

4. Cleanup/Remove all

```sh
terraform destroy -auto-approve -var-file="../secret.tfvars"
```