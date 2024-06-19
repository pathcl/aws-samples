# SPDX-License-Identifier: MIT

FROM golang:1.21.5 AS build

ARG garm_repo=https://github.com/pathcl/aws-samples
ARG garm_repo_ref=v0.1.4

# build garm binary
# primarly used to get the binary build for
# the local CPU architecture
RUN git clone $garm_repo garm_repo && \
  cd garm_repo && \
  git checkout $garm_repo_ref && \
  CGO_ENABLED=1 go install -ldflags "-linkmode external -extldflags '-static' -X main.Version=$garm_repo_ref" ./cmd/garm && \
  CGO_ENABLED=1 go install -ldflags "-linkmode external -extldflags '-static' -X main.Version=$garm_repo_ref" ./cmd/garm-cli

RUN git clone https://github.com/pathcl/aws-samples aws-samples && \
  cd aws-samples && \
  git rev-parse HEAD && \
  sleep 10 && \
  CGO_ENABLED=1 go build -ldflags "-linkmode external -extldflags '-static'" -o /go/bin/test-iam

FROM bitnami/minideb:bookworm

WORKDIR /opt/garm/

ENV PATH="${PATH}:/opt/garm/bin"

COPY --from=build /go/bin/test-iam ./bin/test-iam

COPY ./bin/test-iam ./bin/test-iam

RUN chmod +x ./bin/test-iam && \
  apt-get update && \ 
  apt-get install curl ca-certificates awscli -y && \
  mkdir /.aws && \
  chmod 777 /.aws && \
  update-ca-certificates

USER 65543:65543

EXPOSE 9997

ENTRYPOINT ["sleep", "10h"]
