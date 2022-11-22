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

Download `source_env_var.sh.sample` from [terraform-provider-packetfabric](https://github.com/PacketFabric/terraform-provider-packetfabric/tree/main/examples). Edit `source_env_var.sh.sample` as needed and rename it to `source_env_var.sh`.

```sh
cd <your-terraform-directory>
docker run --rm -it -v $(pwd):/working -v ~/Documents/source_env_var.sh:/working/source_env_var.sh --entrypoint=zsh terraform-runner
```

See available alias:
```sh
alias
```
