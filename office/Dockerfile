# Office Werkomgeving VM
FROM ubuntu:22.04

# Voorkom interactieve prompts
ENV DEBIAN_FRONTEND=noninteractive

# Installeer basis packages en office tools
RUN apt-get update && apt-get install -y \
    # Office-achtige applicaties
    libreoffice \
    libreoffice-calc \
    libreoffice-writer \
    libreoffice-base \
    # Python en database tools
    python3 \
    python3-pip \
    python3-venv \
    # Database clients
    mysql-client \
    postgresql-client \
    # Netwerk en systeem tools
    openssh-server \
    sudo \
    curl \
    wget \
    vim \
    htop \
    net-tools \
    iputils-ping \
    # Desktop omgeving (lightweight)
    xfce4 \
    xfce4-goodies \
    xrdp \
    # VNC server voor remote desktop
    tightvncserver \
    # Browser
    firefox \
    && rm -rf /var/lib/apt/lists/*

# Configureer SSH
RUN mkdir -p /var/run/sshd
RUN echo 'root:rootpassword123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Maak office gebruiker
RUN useradd -m -s /bin/bash office && \
    echo 'office:officepassword123' | chpasswd && \
    usermod -aG sudo office

# Configureer XRDP voor remote desktop
RUN echo "xfce4-session" > /home/office/.xsession
RUN chown office:office /home/office/.xsession

# Installeer Python dependencies voor database connectiviteit
RUN pip3 install \
    mysql-connector-python \
    psycopg2-binary \
    pandas \
    openpyxl \
    xlsxwriter \
    matplotlib \
    seaborn \
    jupyter \
    requests

# Maak directories voor office bestanden
RUN mkdir -p /home/office/Documents/Reports \
    && mkdir -p /home/office/Documents/Data \
    && mkdir -p /home/office/Documents/Scripts \
    && chown -R office:office /home/office/Documents

# Kopieer office scripts en templates
COPY scripts/ /home/office/Documents/Scripts/
COPY templates/ /home/office/Documents/Templates/
RUN chown -R office:office /home/office/Documents/

# Kopieer startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose poorten
EXPOSE 22 3389 5901

# Start services
CMD ["/start.sh"]
