
# Stage 1: Main Build
# Python 3.11 tag
FROM python:3.11.9-bookworm AS main-build
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

WORKDIR /app

ENV USERNAME=user

RUN apt-get update && \
    apt-get install --no-install-recommends -y sudo=1.9.13p3-1+deb12u1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    adduser --disabled-password --gecos '' "$USERNAME" && \
    adduser "$USERNAME" sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT [ "/bin/bash", "-c" ]

# Stage 2: Dev tests build
FROM main-build AS dev-tests-build
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

USER root
RUN apt-get update && \
    apt-get install --no-install-recommends -y shellcheck=0.9.0-1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --progress=dot:giga -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64 && \
    chmod +x /bin/hadolint

COPY requirements-pip-tools.txt requirements-pip-tools.txt
RUN pip install --no-cache-dir -r requirements-pip-tools.txt
USER $USERNAME

COPY requirements-dev.txt requirements-dev.txt
RUN pip install --no-cache-dir -r requirements-dev.txt
ENTRYPOINT [ "/bin/bash", "-c" ]

# Stage 3: Dev-env build: This stage is used as development environment.
FROM dev-tests-build AS dev-env-build
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Give your host machine's docker GID 'getent group docker | cut -d: -f3'
ARG HOST_DOCKER_GID=999

USER root
RUN if ! getent group "$HOST_DOCKER_GID" > /dev/null; then groupadd -g "$HOST_DOCKER_GID" docker_host; fi && \ 
    apt-get update && \
    apt-get install --no-install-recommends -y docker.io=20.10.24+dfsg1-1+b3 \
    vim=2:9.0.1378-2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    usermod -aG "$(getent group $HOST_DOCKER_GID | cut -d: -f1)" "$USERNAME"
USER $USERNAME
ENTRYPOINT [ "/bin/bash", "-c" ]




