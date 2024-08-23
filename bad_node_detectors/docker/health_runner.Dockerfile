FROM ubuntu:latest

WORKDIR /app

RUN apt-get update &&\
    apt-get install -y git make gcc g++ util-linux software-properties-common openssh-server ca-certificates curl jq &&\
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&\
    chmod +x kubectl

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd &&\
  ssh-keygen -t rsa -f /root/.ssh/google_compute_engine -b 2048 -P "" &&\
  cp /root/.ssh/google_compute_engine.pub /root/.ssh/authorized_keys &&\
  chmod 644 /root/.ssh/authorized_keys &&\
  chmod 644 /root/.ssh/google_compute_engine.pub

COPY src/health_runner/health_runner.py .
COPY src/checker_common.py .
COPY src/gpu_healthcheck/gpu_healthcheck.yaml .
COPY src/nccl_healthcheck/a3/ a3/
COPY src/nccl_healthcheck/a3plus/  a3plus/
COPY src/neper_healthcheck/neper_healthcheck.yaml .


RUN chmod -R g+rwx /app/
RUN chgrp -R 1000 /app/

ENV PYTHONUNBUFFERED=1

CMD ["python3", "/app/health_runner.py"]