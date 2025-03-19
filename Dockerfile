ARG PROMTOOL_VERSION=v2.47.2
ARG UBUNTU_VERSION=22.04
ARG PLATFORM=linux/amd64

FROM --platform=${PLATFORM} prom/prometheus:$PROMTOOL_VERSION as prometheus


FROM --platform=${PLATFORM} ubuntu:${UBUNTU_VERSION}

RUN apt-get update && apt-get install -y make jsonnet python3 python3-pip sed \
    && pip3 install pyyaml \
    && pip install ruamel.yaml

COPY --from=prometheus /bin/promtool /bin/promtool

WORKDIR /app
