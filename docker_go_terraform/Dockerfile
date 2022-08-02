FROM hashicorp/terraform:latest

RUN apk add go
RUN apk add make

WORKDIR /working

COPY . /working

RUN cd /working/terraform-provider-packetfabric;make install
RUN mv /root/.terraform.d/plugins/$(hostname) /root/.terraform.d/plugins/terraform.local

RUN echo 'alias ta="terraform apply -var-file=secret.tfvars"' >> ~/alias
RUN echo 'alias td="terraform destroy -var-file=secret.tfvars"' >> ~/alias
RUN echo 'alias ti="terraform init"' >> ~/alias