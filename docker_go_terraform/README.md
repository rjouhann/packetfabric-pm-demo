# Install Docker
* Install [Docker](https://docs.docker.com/get-docker/)
* Or [Podman](https://podman.io/)

# Build

```sh
git clone git@github.com:PacketFabric/terraform-provider-packetfabric.git
cd terraform-provider-packetfabric
git checkout <your-branch>
cd -
docker build -t terraform-runner .
```

# Run
```sh
cd <your-terraform-directory>
docker run --rm -it -v $(pwd):/working -v ~/Documents/secret.tfvars:/working/secret.tfvars --entrypoint=zsh terraform-runner
```

See available alias:
```sh
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
