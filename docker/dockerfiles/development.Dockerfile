FROM ubuntu:20.04 as builder

WORKDIR /dist

ARG BUILD_PACKAGES="\
  wget \
  unzip"

ARG TF_VER=1.1.3

RUN apt-get update && \
  apt-get install -y ${BUILD_PACKAGES} && \
  wget https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip && \
  unzip terraform_${TF_VER}_linux_amd64.zip


FROM ubuntu:20.04

WORKDIR /code

ARG DEV_PACKAGES="\
  git \
  make"

ARG USERNAME
ARG USER_UID
ARG USER_GID

COPY --from=builder /dist/terraform /bin/terraform

RUN apt-get update && \
  apt-get install -y ${DEV_PACKAGES}

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown -R $USER_UID:$USER_GID /home/$USERNAME

USER ${USERNAME}

ENTRYPOINT ["tail", "-f", "/dev/null"]
