# Linux iptables Router VM voor netwerk segmentatie en firewall
FROM ubuntu:22.04

# Set environment to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install networking tools and services
RUN apt-get update && apt-get install -y \
    iptables \
    iptables-persistent \
    netfilter-persistent \
    iproute2 \
    iputils-ping \
    net-tools \
    openssh-server \
    nginx \
    sudo \
    vim \
    htop \
    tcpdump \
    nmap \
    dnsutils \
    curl \
    wget \
    ufw \
    fail2ban \
    wireguard \
    wireguard-tools \
    qrencode \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd
RUN echo 'root:rootpassword123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create router admin user
RUN useradd -m -s /bin/bash routeradmin && \
    echo 'routeradmin:routerpassword123' | chpasswd && \
    usermod -aG sudo routeradmin

# Enable IP forwarding
RUN echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
RUN echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf

# Create router configuration directory
RUN mkdir -p /etc/iptables-router/config
RUN mkdir -p /var/log/iptables-router
RUN mkdir -p /etc/wireguard
RUN mkdir -p /etc/wireguard/clients

# Copy router configuration files
COPY config/ /etc/iptables-router/config/
COPY scripts/ /usr/local/bin/

# Make scripts executable
RUN chmod +x /usr/local/bin/*.sh

# Copy router web interface
COPY webui/ /var/www/html/

# Configure nginx for router web interface
COPY nginx.conf /etc/nginx/nginx.conf

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports
EXPOSE 22 80 443 51820/udp

# Start router services
CMD ["/start.sh"]
