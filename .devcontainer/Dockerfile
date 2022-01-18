FROM ubuntu as builder

WORKDIR /dist

RUN apt-get update && \
  apt-get install -y wget unzip && \
  wget https://releases.hashicorp.com/terraform/1.1.3/terraform_1.1.3_linux_amd64.zip && \
  unzip terraform_1.1.3_linux_amd64.zip

FROM ubuntu

COPY --from=builder /dist/terraform /bin/terraform

RUN apt-get update && \
  apt-get install -y git

ENTRYPOINT ["/bin/bash"]
