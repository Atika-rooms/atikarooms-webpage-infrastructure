ARG TERRA_VER=1.2

FROM registry.gitlab.com/gitlab-org/terraform-images/releases/${TERRA_VER}:latest as lint-builder

LABEL maintainer="Arnau Llamas <arnau.llamas@gmail.com>"

WORKDIR /dist

ARG BUILD_PACKAGES="\
  unzip \
  sudo \
  bash \
  "

RUN apk add --no-cache ${BUILD_PACKAGES}

RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash \
  && mv /usr/local/bin/tflint .


FROM golang:latest as sec-builder

RUN go install github.com/aquasecurity/tfsec/cmd/tfsec@latest


FROM registry.gitlab.com/gitlab-org/terraform-images/releases/${TERRA_VER}:latest

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

COPY --from=sec-builder /go/bin/tfsec /bin/tfsec
COPY --from=lint-builder /dist/tflint /bin/tflint

RUN apk add --no-cache ${DEV_PACKAGES}

RUN addgroup -g $USER_GID $USERNAME \
  && adduser -u $USER_UID -D -s /bin/sh $USERNAME -G $USERNAME \
  && chown -R $USER_UID:$USER_GID /home/$USERNAME

USER ${USERNAME}

ENTRYPOINT ["tail", "-f", "/dev/null"]
