# Install Docker
* Install [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/)

# Build

Make sure you are in ``docker_go_packetfabric_terraform`` folder, clone the ``terraform-provider-packetfabric`` repository and switch to the branch you want to use.

```sh
git clone git@github.com:PacketFabric/terraform-provider-packetfabric.git
cd terraform-provider-packetfabric
git checkout <your-branch>
```

Then go back to the ``docker_go_packetfabric_terraform`` and build the ``terraform-runner`` container.

```sh
cd -
docker rmi terraform-runner
docker build -t terraform-runner .
docker images
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
