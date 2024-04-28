FROM python:3.11

SHELL ["/bin/bash", "-c"]

WORKDIR /app

ENV USERNAME=user

RUN apt-get update && \
    apt-get install -y sudo && \
    apt-get install -y vim && \
    apt-get clean

RUN adduser --disabled-password --gecos '' "$USERNAME" && \
    adduser "$USERNAME" sudo && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Tools to handle requirements.
COPY requirements-pip-tools.txt requirements-pip-tools.txt
RUN pip install -r requirements-pip-tools.txt

USER user

# Test that requirements are valid.
COPY requirements.in requirements.in
COPY requirements.txt requirements.txt
RUN diff -u <(cat requirements.txt) \
    <(pip-compile --dry-run --quiet --no-strip-extras requirements.in 2>&1) || \
    (echo "requirements.txt needs update. \
    Run 'pip-compile --no-strip-extras requirements.in' to update it." && exit 1) >&2

RUN pip install -r requirements.txt


