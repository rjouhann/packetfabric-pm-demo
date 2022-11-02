FROM hashicorp/terraform:latest

RUN apk add go
RUN apk add make
RUN apk add zsh
RUN apk add graphviz
RUN apk add curl
RUN apk add python3
RUN apk add jq
RUN apk add bash

RUN go install github.com/pcasteran/terraform-graph-beautifier@latest

WORKDIR /working

RUN curl -o /root/google-cloud-cli-403.0.0-linux-x86_64.tar.gz -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-403.0.0-linux-x86_64.tar.gz
RUN tar -xf /root/google-cloud-cli-403.0.0-linux-x86_64.tar.gz -C /root
RUN  /root/google-cloud-sdk/install.sh --quiet
ENV PATH="${PATH}:/root/google-cloud-sdk/bin"

COPY resources /working

# PacketFabric
RUN cd /working/terraform-provider-packetfabric;make install
RUN mv /root/.terraform.d/plugins/$(hostname) /root/.terraform.d/plugins/terraform.local

# # AWS
# # https://hashicorp.github.io/terraform-provider-aws/development-environment/
# RUN cd /working/terraform-provider-aws;make build
# RUN echo 'provider_installation {dev_overrides {"hashicorp/aws" = "/root/go/bin","PacketFabric/packetfabric" = "/root/.terraform.d/plugins/terraform.local/packetfabric/packetfabric/0.0.1/linux_amd64"}direct {}}' > /root/.terraformrc

RUN echo 'alias ta="terraform apply -compact-warnings -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias td="terraform destroy -compact-warnings -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias taa="terraform apply -compact-warnings -auto-approve -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias tdd="terraform destroy -compact-warnings -auto-approve -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias ti="terraform init"' >> ~/.zshrc
RUN echo 'alias tim="terraform import -compact-warnings -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias tg="terraform graph | /root/go/bin/terraform-graph-beautifier --exclude=\"module.root.var.*\" --exclude=\"module.root.random\" --exclude=\"module.root.data.*\" --exclude=\"module.root.output.*\"  --output-type=graphviz | dot -Tsvg > graph.svg"' >> ~/.zshrc
RUN echo 'alias cleanup="rm -f *state*;rm -f .*lock*;rm -fr .terraform;rm -fr .terraform.lock.hcl"' >> ~/.zshrc
RUN echo 'alias debugon="export TF_LOG=\"DEBUG\""' >> ~/.zshrc
RUN echo 'alias traceon="export TF_LOG=\"TRACE\""' >> ~/.zshrc
RUN echo 'alias debugoff="export TF_LOG=\"\""' >> ~/.zshrc

CMD [ "zsh" ]