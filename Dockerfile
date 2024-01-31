# syntax=docker/dockerfile:1
FROM ubuntu:jammy-20230816

ARG KCL_PROPERTY_FILE

RUN \
  rm -f /etc/apt/apt.conf.d/docker-clean; \
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y gnupg curl && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv f23c5a6cf475977595c89f51ba6932366a755776 && \
  echo "deb https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/python.list && \
  echo "deb-src https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" >> /etc/apt/sources.list.d/python.list && \
  curl https://apt.corretto.aws/corretto.key | apt-key add - && \
  echo "deb https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list && \
  apt-get update && \
  apt-get install -y python3.11 python3-pip java-11-amazon-corretto-jdk && \
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

WORKDIR /app

RUN curl -sSL https://install.python-poetry.org | python3 - --version 1.6.1
ENV PATH=$PATH:/root/.local/bin

COPY run.sh amazon_kclpy_helper.py main.py $KCL_PROPERTY_FILE ./
COPY pyproject.toml poetry.lock ./

# @see https://docs.docker.com/develop/develop-images/build_enhancements/#using-ssh-to-access-private-data-in-builds
RUN --mount=type=ssh \
    --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/root/.cache/pypoetry/cache \
    --mount=type=cache,target=/root/.cache/pypoetry/artifacts \
  poetry install --no-root

RUN --mount=type=ssh \
    --mount=type=cache,target=/root/.cache/pip \
    --mount=type=cache,target=/root/.cache/pypoetry/cache \
    --mount=type=cache,target=/root/.cache/pypoetry/artifacts \
  poetry install --only-root

ENTRYPOINT ["bash", "/app/run.sh"]
