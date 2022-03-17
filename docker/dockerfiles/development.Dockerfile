FROM ubuntu:20.04 as builder

WORKDIR /dist

ARG BUILD_PACKAGES="\
  wget \
  unzip"

ARG TF_VER=1.1.7
ARG TFSEC_VER=v1.9.0
ARG TFLINT_VER=v0.34.1

RUN apt-get update && \
  apt-get install -y ${BUILD_PACKAGES}

RUN wget https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip && \
  unzip terraform_${TF_VER}_linux_amd64.zip

RUN wget https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VER}/tfsec-linux-amd64 && \
  chmod +x tfsec-linux-amd64

RUN wget https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VER}/tflint_linux_amd64.zip && \
  unzip tflint_linux_amd64.zip

FROM ubuntu:20.04

WORKDIR /code

ARG DEV_PACKAGES="\
  git \
  make"

ARG USERNAME
ARG USER_UID
ARG USER_GID

COPY --from=builder /dist/terraform /bin/terraform
COPY --from=builder /dist/tfsec-linux-amd64 /bin/tfsec
COPY --from=builder /dist/tflint /bin/tflint

RUN apt-get update && \
  apt-get install -y ${DEV_PACKAGES}

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown -R $USER_UID:$USER_GID /home/$USERNAME

USER ${USERNAME}

ENTRYPOINT ["tail", "-f", "/dev/null"]
