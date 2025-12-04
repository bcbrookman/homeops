FROM ghcr.io/actions/actions-runner@sha256:ee54ad8776606f29434f159196529b7b9c83c0cb9195c1ff5a7817e7e570dcfe

LABEL org.opencontainers.image.source=https://github.com/bcbrookman/homeops
LABEL org.opencontainers.image.description="Customized GitHub Actions Runner for HomeOps CI/CD"

USER root

# Install Task
RUN curl -L https://github.com/go-task/task/releases/download/v3.45.5/task_linux_amd64.tar.gz \
 | tar xvzf - \
 && mv task /usr/local/bin/

# Install SOPS
RUN curl -L https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64 \
 --output /tmp/sops \
 && mv /tmp/sops /usr/local/bin/ \
 && chmod +x /usr/local/bin/sops

# Install Terraform
RUN curl -L https://releases.hashicorp.com/terraform/1.4.4/terraform_1.4.4_linux_amd64.zip \
 --output /tmp/terraform.zip \
 && unzip -o /tmp/terraform.zip -d /tmp/terraform/ \
 && mv /tmp/terraform/terraform /usr/local/bin/ \
 && rm -rf /tmp/*

# Install Kustomize
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.8.0/kustomize_v5.8.0_linux_amd64.tar.gz \
 | tar -xvzf - \
 && mv kustomize /usr/local/bin/

# Install Kubeconform
RUN curl -L https://github.com/yannh/kubeconform/releases/download/v0.7.0/kubeconform-linux-amd64.tar.gz \
 | tar xvzf - \
 && mv kubeconform /usr/local/bin/

# Install Python
RUN apt update \
 && add-apt-repository -y ppa:deadsnakes/ppa \
 && apt install -y python3.12 \
 && ln -sf /usr/bin/python3.12 /usr/bin/python3 \
 && curl -L https://bootstrap.pypa.io/get-pip.py --output /tmp/get-pip.py \
 && python3 /tmp/get-pip.py --break-system-packages \
 && pip3 config set global.break-system-packages true \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/*

# Install Requirements
RUN --mount=type=bind,source=./,target=./ \
 task --taskfile tasks.yaml all \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

USER runner
