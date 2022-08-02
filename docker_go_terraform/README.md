# Build

```sh
git clone git@github.com:PacketFabric/terraform-provider-packetfabric.git
git checkout <your-branch>
docker build -t terraform-runner .
```

# Run
```sh
cd <your-terraform-directory>
docker run --rm -it -v $(pwd):/working -v ~/Documents/secret.tfvars:/working/secret.tfvars --entrypoint=sh terraform-runner
```

Load alias:
```sh
source ~/alias
alias
```

# Use the local Terradform provider
```sh
terraform {
  required_providers {
    packetfabric = {
      source  = "terraform.local/PacketFabric/packetfabric"
      version = "~> 0.0.0"
    }
  }
}
```
