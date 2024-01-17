# Use AlmaLinux as the base image
FROM almalinux:latest

# Install dependencies for downloading and installing tools
RUN yum update -y && yum upgrade -y

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# Install talosctl
RUN curl -LO https://github.com/siderolabs/talos/releases/latest/download/talosctl-linux-amd64 \
    && chmod +x talosctl-linux-amd64 \
    && mv talosctl-linux-amd64 /usr/local/bin/talosctl

# Create a directory to store config files
RUN mkdir -p /root/configs

# Copy the kubeconfig and talosconfig files from your host to the container
COPY configs/kubeconfig /root/configs/kubeconfig
COPY configs/talosconfig /root/configs/talosconfig

# Set environment variables
ENV KUBECONFIG=/root/configs/kubeconfig
ENV TALOSCONFIG=/root/configs/talosconfig

# The CMD directive is optional, adjust it to your preferred default command
CMD ["tail", "-f", "/dev/null"]
