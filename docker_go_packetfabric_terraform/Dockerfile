FROM hashicorp/terraform:latest

RUN apk add go
RUN apk add make
RUN apk add zsh
RUN apk add graphviz

RUN go install github.com/pcasteran/terraform-graph-beautifier@latest

WORKDIR /working

COPY . /working

RUN cd /working/terraform-provider-packetfabric;make install
RUN mv /root/.terraform.d/plugins/$(hostname) /root/.terraform.d/plugins/terraform.local

RUN echo 'alias ta="terraform apply -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias td="terraform destroy -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias taa="terraform apply -auto-approve -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias tdd="terraform destroy -auto-approve -var-file=secret.tfvars"' >> ~/.zshrc
RUN echo 'alias ti="terraform init"' >> ~/.zshrc
RUN echo 'alias tg="terraform graph | /root/go/bin/terraform-graph-beautifier --exclude=\"module.root.var.*\" --exclude=\"module.root.random\" --exclude=\"module.root.data.*\" --exclude=\"module.root.output.*\"  --output-type=graphviz | dot -Tsvg > graph.svg"' >> ~/.zshrc
RUN echo 'alias cleanup="rm -fr *state* .*lock* .terraform"' >> ~/.zshrc
RUN echo 'alias debugon="export TF_LOG=\"DEBUG\""' >> ~/.zshrc
RUN echo 'alias debugoff="export TF_LOG=\"\""' >> ~/.zshrc

CMD [ "zsh" ]