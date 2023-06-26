
# this is an updated version of jfbrandhorst/grpc-web-generators : https://github.com/johanbrandhorst/grpc-web-generators

# TODO multistage build to reduce image size

# Build stage

FROM ubuntu:latest as build

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/app
#COPY ./ /usr/app

RUN apt-get update && apt-get install -y \
    automake \
    build-essential \
    git \
    libtool \
    make \
    npm \
    wget \
    unzip \
    libprotoc-dev \
    python3-pip \
    golang

## Install protoc

ENV PROTOBUF_VERSION 23.3

RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOBUF_VERSION/protoc-$PROTOBUF_VERSION-linux-x86_64.zip && \
    unzip protoc-$PROTOBUF_VERSION-linux-x86_64.zip -d /usr/local/ && \
    rm -rf protoc-$PROTOBUF_VERSION-linux-x86_64.zip

## Install protoc-gen-go

ENV PROTOC_GEN_GO_VERSION v1.5.3

RUN git clone https://github.com/golang/protobuf /root/go/src/github.com/golang/protobuf && \
    cd /root/go/src/github.com/golang/protobuf && \
    git fetch --all --tags --prune && \
    git checkout tags/$PROTOC_GEN_GO_VERSION && \
    go install ./protoc-gen-go && \
    ln -s /root/go/bin/protoc-gen-go /usr/local/bin/protoc-gen-go && \
    rm -rf /root/go/src

## Install protoc-gen-grpc-web

ENV PROTOC_GEN_GRPC_WEB_VERSION 1.4.2

RUN git clone https://github.com/grpc/grpc-web /github/grpc-web && \
    cd /github/grpc-web && \
    git fetch --all --tags --prune && \
    git checkout tags/$PROTOC_GEN_GRPC_WEB_VERSION && \
    make install-plugin && \
    rm -rf /github

## Install protoc-gen (npm)

#WORKDIR /usr/app/protoc-gen

ENV PROTOC_GEN_GRPC_VERSION 2.0.4

#google-protobuf@$PROTOBUF_VERSION

RUN npm install protoc-gen-grpc@$PROTOC_GEN_GRPC_VERSION  && \
    ln -s ./node_modules/.bin/protoc-gen-grpc /usr/local/bin/protoc-gen-grpc

## Install protoc-gen-ts

#WORKDIR /usr/app/protoc-gen-ts

ENV PROTOC_GEN_TS_VERSION 0.15.0
# google-protobuf@$PROTOBUF_VERSION

RUN npm install ts-protoc-gen@$PROTOC_GEN_TS_VERSION  && \
    ln -s ./node_modules/.bin/protoc-gen-ts /usr/local/bin/protoc-gen-ts


## Install protoc-gen-python

RUN pip3 install grpcio-tools

# deployment stage: using previous build to reduce image size

# FROM build as deploy

# copy all build files to new image

# COPY --from=build /usr/local/bin/protoc-gen-go /usr/local/bin/protoc-gen-go
# COPY --from=build /usr/local/bin/protoc-gen-grpc-web /usr/local/bin/protoc-gen-grpc-web
# COPY --from=build /usr/local/bin/protoc-gen-grpc /usr/local/bin/protoc-gen-grpc
# COPY --from=build /usr/local/bin/protoc-gen-ts /usr/local/bin/protoc-gen-ts
# COPY --from=build /usr/local/bin/protoc-gen-python /usr/local/bin/protoc-gen-python

# COPY --from=build /usr/local/include/google /usr/local/include/google
# COPY --from=build /usr/local/include/grpc /usr/local/include/grpc
# COPY --from=build /usr/local/include/grpcpp /usr/local/include/grpcpp
# COPY --from=build /usr/local/lib/libgrpc++_reflection.a /usr/local/lib/libgrpc++_reflection.a



