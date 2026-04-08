FROM hashicorp/terraform:1.6.2

# Install curl + bash
RUN apk add --no-cache curl bash git openssl

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installations
RUN terraform version
RUN helm version
