# terraform-packetfabric-pm-demo

## Quick Start

1. Create the file ``secret.tfvars`` and update each variables.

```sh
cp secret.tfvars.sample secret.tfvars
```

2. Choose the folder between 

- AWS initial setup (create VPC, subnets, ec2, etc...):<br/>``cd aws_initial_setup``
- Azure initial setup (create VNet, subnets, VM, etc...) + Azure Cloud Router Connection:<br/>``cd azure_initial_setup``
- GCP initial setup (create VPC, subnets, VM, etc...) + GCP Cloud Router Connection:<br/>``cd gcp_initial_setup``
- PacketFabric Cloud Router + AWS/Azure/Google Cloud Router Connections:<br/>``cd pf_cloud_router_demo`` (run all previous ``<csp>_initial_setup`` first)
- AWS Peering Connections (native AWS):<br/>``cd aws_peering_connections``

3. Create resources 
```sh
terraform init
terraform apply -auto-approve -var-file="../secret.tfvars"
```

4. Cleanup/Remove all

```sh
terraform destroy -auto-approve -var-file="../secret.tfvars"
```

Only for ``pf_cloud_router_demo``:

```sh
terraform destroy -auto-approve -var-file="../secret.tfvars"
```
