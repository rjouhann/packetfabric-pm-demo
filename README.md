# terraform-packetfabric-pm-demo


## Quick Start

1. Create the file ``secret.tfvars`` and update each variables.

```sh
cp secret.tfvars.sample secret.tfvars
```

2. Choose the folder between 

- AWS initial setup (create VPC, subnets, ec2, etc...): ``cd aws_initial_setup``
- Azure initial setup (create VNet, subnets, VM, etc...) + Azure Cloud Router Connection: ``cd azure_initial_setup_cloud_router_conn``
- GCP initial setup (create VPC, subnets, VM, etc...) + GCP Cloud Router Connection: ``cd gcp_initial_setup_cloud_router_conn``
- PacketFabric Cloud Router + AWS Cloud Router Connection: ``cd pf_cloud_router_aws_demo`` (run ``aws_initial_setup`` first)
- AWS Peering Connections (native AWS): ``cd aws_peering_connections``

3. Create resources 
```sh
terraform init
terraform apply -auto-approve -var-file="../secret.tfvars"
```

4. Cleanup/Remove all

```sh
terraform destroy -auto-approve -var-file="../secret.tfvars"
```

Only for ``pf_cloud_router_aws_demo``:

```sh
terraform state rm cloud_router_bgp_session.crbs_1
terraform state rm cloud_router_bgp_session.crbs_2
terraform state rm cloud_router_bgp_prefixes.crbp_1
terraform state rm cloud_router_bgp_prefixes.crbp_2
terraform destroy -auto-approve -var-file="../secret.tfvars"
```