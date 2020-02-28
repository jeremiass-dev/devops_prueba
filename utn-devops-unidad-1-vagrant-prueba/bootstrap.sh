#!/usr/bin/env bash

apt-get update
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

if [ ! -f "/swapdir/swapfile" ]; then
	sudo mkdir /swapdir
	cd /swapdir
	sudo dd if=/dev/zero of=/swapdir/swapfile bs=1024 count=2000000
	sudo mkswap -f  /swapdir/swapfile
	sudo chmod 600 /swapdir/swapfile
	sudo swapon swapfile
	echo "/swapdir/swapfile       none    swap    sw      0       0" | sudo tee -a /etc/fstab /etc/fstab
	sudo sysctl vm.swappiness=10
	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
fi

## configuración servidor web
#copio el archivo de configuración del repositorio en la configuración del servidor web
if [ -f "/tmp/devops.site.conf" ]; then
	echo "Copio el archivo de configuracion de apache"
	sudo mv /tmp/devops.site.conf /etc/apache2/sites-available
	#activo el nuevo sitio web
	sudo a2ensite devops.site.conf
	#desactivo el default
	sudo a2dissite 000-default.conf
	#refresco el servicio del servidor web para que tome la nueva configuración
	sudo service apache2 reload
fi

APACHE_ROOT="/var/www"

APP_PATH="$APACHE_ROOT/utn-apps"

sudo apt-get update
sudo apt-get install -y php7.2
php -v

if [ ! -d "$APP_PATH" ]; then
	echo "clono el repositorio"
	cd $APACHE_ROOT
	#sudo git clone https://github.com/Fichen/utn-devops-app.git
	#sudo git clone git@github.com:gabogosp/utn-apps.git
	git clone https://github.com/jeremiass-dev/utn-apps.git
	cd $APP_PATH
	git checkout unidad-1
	git pull
fi
