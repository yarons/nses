#!/bin/bash
set -xuo pipefail

NSES() {
	add-apt-repository ppa:certbot/certbot -y
	apt-get update -y && apt-get upgrade -y
	apt-get install unattended-upgrades tree zip unzip python-certbot-nginx -y
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
	mkdir /root/backups /root/backups/db /root/backups/dirs

	cd /usr/src && rm -fv csf.tgz
	wget https://download.configserver.com/csf.tgz && tar -xzf csf.tgz
	cd csf && sh install.sh
	sed -i 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf
	csf -r && perl /usr/local/csf/bin/csftest.pl
	# sh /etc/csf/uninstall.sh

	cd /usr/local/src && wget http://www.rfxn.com/downloads/maldetect-current.tar.gz && tar -xzfv maldetect-current.tar.gz
	cd maldetect-* && bash ./install.sh

	apt-get install nginx mysql-server php-fpm php-mysql php-mbstring php-mcrypt -y
	sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.0/fpm/php.ini
	sed -i 's/post_max_size \= .M/post_max_size \= 200M/g' /etc/php/7.0/fpm/php.ini # regex dot.
	sed -i 's/upload_max_filesize \= .M/upload_max_filesize \= 200M/g' /etc/php/7.0/fpm/php.ini
	/etc/init.d/php7.0-fpm restart # MBP.
	systemctl restart nginx.service

	cat <<-'WSM' > /etc/nginx/sites-available/wsm.sh
		#!/bin/sh
		for domain; do
			cat << SBLOCK > "/etc/nginx/sites-available/${domain}.conf" 
				server {
					root /var/www/html/${DOMAIN};
					server_name ${DOMAIN} www.${DOMAIN};

					location ~ /\.ht {
						deny all; 
					}

					location ~*  \.(jpg|jpeg|png|gif|ico|css|js|ttf|woff|pdf)$ {
						expires 365d; 
					}

					location / {
						index index.php index.html index.htm fastcgi_index;
						try_files $uri $uri =404 $uri/ /index.php?$args;
					}

					location ~ \.php$ {
						fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
						fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
						include fastcgi_params;
					}
				}
			SBLOCK
			ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/

			mysql -u root -p << MYSQL
				create user '${DOMAIN}'@'localhost' identified by '$DOMAIN';
				create database ${DOMAIN};
				GRANT ALL PRIVILEGES ON ${DOMAIN}.* TO ${domain}@localhost;
			MYSQL

			certbot --nginx -d ${DOMAIN} -d www.${DOMAIN}
		done
		cd /var/www/html && wget http://wordpress.org/latest.tar.gz && tar xfz latest.tar.gz && rm latest.tar.gz
		cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
		mv wordpress ${domain}
		chown www-data /var/www/html/ -R && chgrp www-data /var/www/html/ -R
		find /var/www/html/* -type d -exec chmod 755 {} \; && find /var/www/html/* -type f -exec chmod 644 {} \;
		systemctl restart nginx.service
		echo 'Web Substrate created. Please change password for your new DB user.'
	WSM
	chmod +x /etc/nginx/sites-available/wsm.sh

	cat <<-'MANUAL_BACKUP' > /opt/backup.sh
		zip -r /var/www/html/html-$(date +\%F-\%T).zip /var/www/html -x '*wp-content/cache*'

		mysqldump -u root -p --all-databases > /var/www/html/db-$(date +\%F-\%T).sql
		zip /var/www/html/db-$(date +\%F-\%T).zip /var/www/html/db-*.sql
		rm /var/www/html/db-*.sql
	MANUAL_BACKUP
	chmod +x /opt/backup.sh

	cat <<-'BASHRC' >> /etc/bash.bashrc

		alias brc="nano /etc/bash.bashrc"
		alias wsm="bash /etc/nginx/sites-available/wsm.sh"
		alias rss="systemctl restart nginx.service"
		alias www="cd /var/www/html"
		alias imb="bash /opt/backup.sh"
	BASHRC
}
NSES
