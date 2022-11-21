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

RUN wget https://github.com/hashicorp/terraform-plugin-docs/releases/download/v0.13.0/tfplugindocs_0.13.0_linux_amd64.zip -P /root
RUN unzip /root/tfplugindocs_0.13.0_linux_amd64.zip -d /root/
RUN cp /root/tfplugindocs /usr/bin

COPY terraform-provider-packetfabric /working

RUN cd /working/terraform-provider-packetfabric; make install

RUN mv /root/.terraform.d/plugins/$(hostname)/packetfabric/packetfabric/0.0.1/linux_amd64/terraform-provider-packetfabric /root/go/bin
# https://github.com/PacketFabric/terraform-provider-packetfabric#developing-the-provider
RUN echo 'provider_installation {dev_overrides {"PacketFabric/packetfabric" = "/root/go/bin"}direct {}}' > /root/.terraformrc

RUN echo 'alias ta="terraform apply -compact-warnings"' >> ~/.zshrc
RUN echo 'alias td="terraform destroy -compact-warnings"' >> ~/.zshrc
RUN echo 'alias taa="terraform apply -compact-warnings -auto-approve"' >> ~/.zshrc
RUN echo 'alias tdd="terraform destroy -compact-warnings -auto-approve"' >> ~/.zshrc
RUN echo 'alias ti="source /working/source_env_var.sh;terraform init"' >> ~/.zshrc
RUN echo 'alias tim="terraform import -compact-warnings"' >> ~/.zshrc
RUN echo 'alias tg="terraform graph | /root/go/bin/terraform-graph-beautifier --exclude=\"module.root.var.*\" --exclude=\"module.root.random\" --exclude=\"module.root.data.*\" --exclude=\"module.root.output.*\"  --output-type=graphviz | dot -Tsvg > graph.svg"' >> ~/.zshrc
RUN echo 'alias cleanup="rm -f *state*;rm -f .*lock*;rm -fr .terraform;rm -fr .terraform.lock.hcl"' >> ~/.zshrc
RUN echo 'alias debugon="export TF_LOG=\"DEBUG\""' >> ~/.zshrc
RUN echo 'alias traceon="export TF_LOG=\"TRACE\""' >> ~/.zshrc
RUN echo 'alias debugoff="export TF_LOG=\"\""' >> ~/.zshrc
RUN echo 'alias coverage="cd /working/internal/provider; go test -cover -v | grep -v SKIP | grep -v testutil.go | grep -v PASS | grep -v github.com"'  >> ~/.zshrc
RUN echo 'alias accall="make testacc"' >> ~/.zshrc
RUN echo 'alias acc="cd /working/internal/provider; echo \"TF_ACC=1 go test -v -run=\""' >> ~/.zshrc
RUN echo 'alias fmt="gofmt -l -s -w ."'  >> ~/.zshrc

CMD [ "zsh" ]