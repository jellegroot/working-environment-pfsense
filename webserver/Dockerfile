# Webserver VM met Apache2, ModSecurity WAF en Flask
FROM ubuntu:22.04

# Voorkom interactieve prompts tijdens installatie
ENV DEBIAN_FRONTEND=noninteractive

# Update en installeer basis packages
RUN apt-get update && apt-get install -y \
    apache2 \
    apache2-utils \
    libapache2-mod-security2 \
    modsecurity-crs \
    libapache2-mod-wsgi-py3 \
    python3 \
    python3-pip \
    python3-venv \
    openssh-server \
    sudo \
    curl \
    wget \
    vim \
    htop \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Maak SSH directory en configureer SSH
RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword123' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Maak admin gebruiker
RUN useradd -m -s /bin/bash admin && \
    echo 'admin:Secret_aresse123' | chpasswd && \
    usermod -aG sudo admin

# Configureer Apache modules
RUN a2enmod security2 && \
    a2enmod rewrite && \
    a2enmod ssl && \
    a2enmod headers && \
    a2enmod wsgi

# Remove default ModSecurity config to avoid conflicts
RUN rm -f /etc/modsecurity/modsecurity.conf

# Kopieer Apache configuratie
COPY config/security.conf /etc/apache2/conf-available/
COPY config/webapp.conf /etc/apache2/sites-available/
RUN a2enconf security && \
    a2ensite webapp && \
    a2dissite 000-default

# Installeer Python dependencies
RUN pip3 install flask mysql-connector-python bcrypt

# Maak directories voor de applicatie
RUN mkdir -p /var/www/webapp && \
    chown -R www-data:www-data /var/www/webapp

# Kopieer startup script
COPY scripts/start.sh /start.sh
RUN chmod +x /start.sh

# Expose poorten
EXPOSE 22 80 443

# Start services
CMD ["/start.sh"]
