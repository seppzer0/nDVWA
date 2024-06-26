# step: installing Nginx with Docker
FROM nginx:1.25.4-bookworm
EXPOSE 80
EXPOSE 22

WORKDIR /ndvwa

# step: deploying DVWA on Nginx
# copy config files into container
COPY configs/dvwa.conf /etc/nginx/sites-available/default
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/dbsetup.sql ${WORKDIR}/dbsetup.sql
COPY entrypoint.sh /ndvwa/entrypoint.sh
# install basic packages
RUN apt-get update && \
    apt-get install -y \
        git \
        bash \
        wget \
        nano \
        nmap \
        ufw \
        mariadb-server \
        mariadb-client \
        lsb-release \
        apt-transport-https \
        ca-certificates \
        openssh-server \
        openssh-client \
        sshpass \
        knockd && \
    apt-get autoremove -y
# install a specific version of PHP
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt-get update && \
    apt-get install -y php8.3-fpm php8.3-mysqli
# run configurations
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled /var/www/html && \
    # prepare DVWA files
    git clone --depth 1 https://github.com/digininja/DVWA.git /var/www/html/dvwa && \
    chmod 777 -R /var/www/html/dvwa && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
    # create PHP config
    cp /var/www/html/dvwa/config/config.inc.php.dist /var/www/html/dvwa/config/config.inc.php && \
    # setup database
    service mariadb start && \
    mysql -u root < ${WORKDIR}/dbsetup.sql && \
    # firewall setting for nginx
    ufw allow 80,443/tcp

# setup entrypoint CMD
COPY entrypoint.sh ${WORKDIR}/entrypoint.sh
CMD [ "bash", "/ndvwa/entrypoint.sh" ]
