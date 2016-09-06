FROM ubuntu:14.04

MAINTAINER "Tornike Razmadze" <torniker@gmail.com>

WORKDIR /tmp

# Install Nginx
RUN apt-get update -y && \
	apt-get install -y curl 
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get update -y && \
    apt-get install -y \ 
    git \
    apache2 \
    libtool \
	libzmq-dev \
	pkg-config \
	php5-dev \
	php5-pgsql \
	supervisor \
#	postgresql \
	nodejs

RUN git clone git://github.com/mkoppanen/php-zmq.git /tmp/php-zmq
WORKDIR /tmp/php-zmq
RUN phpize5 && ./configure && make && sudo make install \ 
	echo -e "\nextension=zmq.so" | sudo tee -a /etc/php5/apache2/php.ini \
	echo -e "\nextension=zmq.so" | sudo tee -a /etc/php5/cli/php.ini \
	sudo php5enmod pgsql
RUN mkdir -p /vagrant/web

ADD config/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite 
RUN service apache2 restart
#RUN service postgresql start
#RUN sudo -u postgres psql --command "ALTER USER postgres WITH PASSWORD 'aloha';" 
#RUN sudo -u postgres psql --command "CREATE DATABASE cl_tool;" 
#RUN sudo -u postgres psql --command "\l" 
#sudo -u postgres psql cl_tool < /vagrant/scripts/dump.pgsql

ADD config/web-socket.conf /etc/supervisor/conf.d/web-socket.conf
RUN sudo service supervisor stop \ 
	sudo service supervisor start

## Apply Nginx configuration
#ADD config/nginx.conf /opt/etc/nginx.conf
#ADD config/cl-tool.shift.dev /etc/nginx/sites-available/cl-tool.shift.dev
#RUN ln -s /etc/nginx/sites-available/cl-tool.shift.dev /etc/nginx/sites-enabled/cl-tool.shift.dev && \
#    rm /etc/nginx/sites-enabled/default
#
## Nginx startup script
## ADD config/nginx-start.sh /opt/bin/nginx-start.sh
## RUN chmod u=rwx /opt/bin/nginx-start.sh
#
##RUN mkdir -p /vagrant
VOLUME ["/vagrant"]
## PORTS
EXPOSE 80
#EXPOSE 443