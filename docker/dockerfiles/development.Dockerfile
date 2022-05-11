FROM registry.gitlab.com/gitlab-org/terraform-images/releases/1.1:latest as builder

LABEL maintainer="Arnau Llamas <arnau.llamas@gmail.com>"

WORKDIR /dist

ARG BUILD_PACKAGES="\
  unzip \
  sudo \
  bash \
  "

# TODO: install 'go' to install always latest version
# Bug where newest TFSEC versions do not follow symlinks:
# https://github.com/aquasecurity/tfsec/issues/1595
ARG TFSEC_VERSION=v1.20.2

RUN apk add --no-cache ${BUILD_PACKAGES}

RUN wget https://github.com/aquasecurity/tfsec/releases/download/${TFSEC_VERSION}/tfsec-linux-amd64 \
  && chmod +x tfsec-linux-amd64

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash \
  && mv /usr/local/bin/tflint .


FROM registry.gitlab.com/gitlab-org/terraform-images/releases/1.1:latest

WORKDIR /code

ARG DEV_PACKAGES="\
  make \
  bash \
  gettext \
  moreutils \
  "

ARG USERNAME
ARG USER_UID
ARG USER_GID

COPY --from=builder /dist/tfsec-linux-amd64 /bin/tfsec
COPY --from=builder /dist/tflint /bin/tflint

RUN apk add --no-cache ${DEV_PACKAGES}

RUN addgroup -g $USER_GID $USERNAME \
  && adduser -u $USER_UID -D -s /bin/sh $USERNAME -G $USERNAME \
  && chown -R $USER_UID:$USER_GID /home/$USERNAME

USER ${USERNAME}

ENTRYPOINT ["tail", "-f", "/dev/null"]
