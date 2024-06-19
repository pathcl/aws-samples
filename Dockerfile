# SPDX-License-Identifier: MIT

FROM golang:1.21.5 AS build

RUN git clone https://github.com/pathcl/aws-samples aws-samples && \
  cd aws-samples && \
  git rev-parse HEAD && \
  ls -ltr && \
  sleep 10 && \
  CGO_ENABLED=1 go build -ldflags "-linkmode external -extldflags '-static'" -o /go/bin/test-iam

FROM bitnami/minideb:bookworm

WORKDIR /opt/garm/

ENV PATH="${PATH}:/opt/garm/bin"

COPY --from=build /go/bin/test-iam ./bin/test-iam

# COPY ./bin/test-iam ./bin/test-iam

RUN chmod +x ./bin/test-iam && \
  apt-get update && \ 
  apt-get install curl ca-certificates awscli -y && \
  mkdir /.aws && \
  chmod 777 /.aws && \
  update-ca-certificates

USER 65543:65543

EXPOSE 9997

ENTRYPOINT ["/bin/bash"]
