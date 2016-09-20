#!/usr/bin/make -f
#
# Build website with environment
#
#

# Colors
NO_COLOR		= \033[0m
TARGET_COLOR	= \033[32;01m
OK_COLOR		= \033[32;01m
ERROR_COLOR		= \033[31;01m
WARN_COLOR		= \033[33;01m
ACTION			= $(TARGET_COLOR)--> 
HELPTEXT 		= "$(ACTION)" `egrep "^\# target: $(1) " Makefile | sed "s/\# target: $(1)[ ]\+- / /g"` "$(NO_COLOR)"

WWW_SITE	:= uptime.dbwebb.se
WWW_LOCAL	:= local.$(WWW_SITE)
SERVER_ADMIN := mos@$(WWW_SITE)

GIT_BASE 	= git/$(WWW_SITE)
HTDOCS_BASE = $(HOME)/htdocs
LOCAL_HTDOCS = $(HTDOCS_BASE)/$(WWW_SITE)
ROBOTSTXT	 := robots.txt

# Certificates for https
SSL_APACHE_CONF = /etc/letsencrypt/options-ssl-apache.conf
SSL_PEM_BASE 	= /etc/letsencrypt/live/$(WWW_SITE)

# Theme
LESS 		 = theme/style_dbwebb.less
LESS_OPTIONS = --strict-imports --include-path=theme/mos-theme/style/
FONT_AWESOME = theme/mos-theme/style/font-awesome/fonts/

# Cache
FORUM_CACHE = $(LOCAL_HTDOCS)/htdocs/forum/cache

# Publish
EXCLUDE_ON_PUBLISH = --exclude old --exclude backup --exclude .git --exclude .solution --exclude .solutions --exclude error.log --exclude cache --exclude access.log --delete

# Backup
TODAY = `date +'%y%m%d'`



# target: help - Displays help.
.PHONY:  help
help:
	@echo $(call HELPTEXT,$@)
	@echo "make [target] ..."
	@echo "target:"
	@egrep "^# target:" Makefile | sed 's/# target: / /g'



# target: update-all - Update codebase and publish by clearing the cache.
.PHONY: update-all
update-all: codebase-update submodule-update site-build local-publish-clear
	@echo $(call HELPTEXT,$@)



# target: update - Update codebase (no submodules) and publish by clearing the cache.
.PHONY: update
update: codebase-update site-build local-publish-clear
	@echo $(call HELPTEXT,$@)



# target: production-publish - Publish latest to the production server.
production-publish:
	@echo $(call HELPTEXT,$@)
	ssh -p 2222 mos@$(WWW_SITE) -t "cd $(GIT_BASE) && git pull && make update"



# target: local-publish     - Publish website to local host.
.PHONY: local-publish
local-publish:
	@echo $(call HELPTEXT,$@)
	rsync -av $(EXCLUDE_ON_PUBLISH) --exclude data/uptime.sqlite data htdocs $(LOCAL_HTDOCS)

	chmod 777 $(LOCAL_HTDOCS)/data
	[ ! -d $(LOCAL_HTDOCS)/data/uptime.sqlite ] ||  chmod 666 $(LOCAL_HTDOCS)/data/uptime.sqlite



# target: local-cache-clear - Clear the cache.
.PHONY: local-cache-clear
local-cache-clear:
	@echo $(call HELPTEXT,$@)
	-sudo rm -f $(LOCAL_HTDOCS)/cache/anax/*
	-sudo rm -f $(LOCAL_HTDOCS)/cache/forum/*



# target: local-publish-clear - Publish website to local host and clear the cache.
.PHONY: local-publish-clear
local-publish-clear: local-cache-clear local-publish
	@echo $(call HELPTEXT,$@)



# target: local-publish-forum - Publish website and clear forum template cache.
.PHONY: local-publish-forum
local-publish-forum: local-cache-clear local-publish
	@echo $(call HELPTEXT,$@)
	-sudo rm -f $(LOCAL_HTDOCS)/cache/forum/tpl_dbwebb-v2.0_*



# target: codebase-update    - Update codebase.
.PHONY: codebase-update
codebase-update:
	@echo $(call HELPTEXT,$@)
	git pull
	composer install



# target: forum-init      - Init the forum structure, run after publish.
.PHONY: forum-init
forum-init:
	rsync -av htdocs/forum/files_/ $(LOCAL_HTDOCS)/cache/forum-files/
	chmod -f 666 $(LOCAL_HTDOCS)/cache/forum-files/* || true



# target: submodule-init      - Init all submodules.
# target: submodule-update    - Update all submodules.
.PHONY: submodule-init submodule-update
submodule-init:
	git submodule update --init --recursive 

submodule-update:
	git pull --recurse-submodules && git submodule foreach git pull origin master



# target: server-node-echo    - Start up the echo server.
.PHONY: server-node-echo
server-node-echo:
	@echo $(call HELPTEXT,$@)
	cd $(LOCAL_HTDOCS)/htdocs/repo/javascript/example/lekplats/broadcast-server-with-node-js-and-html5-websockets && nodejs websocket_broadcastserver.js 



# target: backup              - Take a backup of database and other essentials.
.PHONY: backup
backup:
	@echo $(call HELPTEXT,$@)
	install --directory backup/$(TODAY)
	
	# Get database from server
	rsync -av -e "ssh -p 2222" $(WWW_SITE):htdocs/$(WWW_SITE)/data backup/$(TODAY)

	# Point to latest successful backup
	rm -f backup/latest
	ln -s $(TODAY) backup/latest



# target: load-backup             - Load latest backup.
.PHONY: load-backup
load-backup:
	@echo $(call HELPTEXT,$@)
	
	# Forum
	zcat backup/latest/dbw_forum.gz | mysql -uroot dbw_forum
	rsync -a --delete backup/latest/forum/files/ htdocs/forum/files/ 



# target: database-create         - Create needed databases.
.PHONY: database-create
database-create:
	@echo $(call HELPTEXT,$@)
	
	# Forum
	#create database dbw_forum;
	#grant all on dbw_forum.* to 'dbwebb'@'localhost' identified by 'password';

	#create database Anaxoophp; 
	#grant all on Anaxoophp.* to acronym@localhost identified by 'password';  

	#create database Movie; 
	#grant all on Movie.* to 'acronym'@'localhost' identified by 'password';



# target: forum-no-activation    - No activation of new users.
.PHONY: forum-no-activation
forum-no-activation:
	@echo $(call HELPTEXT,$@)
	
	echo "UPDATE phpbb_config SET config_value = 3 WHERE config_name = 'require_activation';" | mysql -uroot dbw_forum


#
# Build
#
.PHONY: prepare-build

prepare-build: 
	rm -rf build
	install -d build/css build/lint



# target: less-update - Build less and update site.
.PHONY: less-update
less-update: less local-publish



# target: less-update-clear - Build less and update site and clear cache.
.PHONY: less-update-clear
less-update-clear: less local-publish-clear



# target: less - Build less stylesheet and update the site with it.
.PHONY: less
less: prepare-build
	#lessc $(LESS_OPTIONS) $(LESS) build/css/style.css
	lessc --clean-css $(LESS_OPTIONS) $(LESS) build/css/style.min.css
	#cp build/css/style.css htdocs/css/style.css
	cp build/css/style.min.css htdocs/css/style.min.css

	rsync -av theme/mos-theme/js/ htdocs/js/mos-theme/
	rsync -av $(FONT_AWESOME) htdocs/fonts/



#
# Lint
#
.PHONY: lint

lint: less
	lessc --lint $(LESS) > build/lint/style.less
	- csslint build/css/style.css > build/lint/style.css
	ls -l build/lint/



# target: site-build   - Create essential directories and copy from vendor.
.PHONY: site-build
site-build:
	# Create and sync cache
	bash -c "install --directory --mode 777 cache/{cimage,anax,forum,forum-files}"
	rsync -av cache $(LOCAL_HTDOCS)

	# Copy from CImage
	install -d htdocs/cimage
	bash -c "rsync -av vendor/mos/cimage/webroot/{img,imgd,imgf,imgp,imgs,check_system}.php vendor/mos/cimage/icc htdocs/cimage"
	rsync -av vendor/mos/cimage/webroot/img/ htdocs/img/cimage/



# target: etc-hosts - Create a entry in the /etc/hosts for local access.
.PHONY: etc-hosts
etc-hosts:
	echo "127.0.0.1 $(WWW_LOCAL)" | sudo bash -c 'cat >> /etc/hosts'
	@tail -1 /etc/hosts



# target: ssl-cert-create - One way to create the certificates.
.PHONY: ssl-cert-create
ssl-cert-create:
	#cd $(HOME)/git/letsencrypt
	#./letsencrypt-auto certonly --standalone -d $(WWW_SITE) -d www.$(WWW_SITE)
	sudo certbot certonly --standalone -d $(WWW_SITE) -d www.$(WWW_SITE)



# target: ssl-cert-update - Update certificates with new expiray date.
.PHONY: ssl-cert-renew
ssl-cert-renew:
	#cd $(HOME)/git/letsencrypt
	#./letsencrypt-auto renew
	sudo certbot renew


# target: install-fresh - Do a fresh installation of a new server.
.PHONY: install-fresh
install-fresh: etc-hosts virtual-host update



# target: virtual-host - Create entries for the virtual host http.
.PHONY: virtual-host

define VIRTUAL_HOST_80
Define site $(WWW_SITE)
ServerAdmin $(SERVER_ADMIN)

<VirtualHost *:80>
	ServerName $${site}
	ServerAlias local.$${site}
	DocumentRoot $(HTDOCS_BASE)/$${site}/htdocs

	<Directory />
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
		Order allow,deny
		Allow from all
	</Directory>

	<FilesMatch "\.(jpe?g|png|gif|js|css|svg|ttf|otf|eot|woff|woff2|ico)$">
		ExpiresActive On
		ExpiresDefault "access plus 1 week"
	</FilesMatch>

	ErrorLog  $(HTDOCS_BASE)/$${site}/error.log
	CustomLog $(HTDOCS_BASE)/$${site}/access.log combined
</VirtualHost>
endef
export VIRTUAL_HOST_80

define VIRTUAL_HOST_80_WWW
Define site $(WWW_SITE)
ServerAdmin $(SERVER_ADMIN)

<VirtualHost *:80>
	ServerName www.$${site}
	Redirect "/" "http://$${site}/"
</VirtualHost>
endef
export VIRTUAL_HOST_80_WWW

virtual-host:
	install --directory $(LOCAL_HTDOCS)/htdocs
	echo "$$VIRTUAL_HOST_80" | sudo bash -c 'cat > /etc/apache2/sites-available/$(WWW_SITE).conf'
	echo "$$VIRTUAL_HOST_80_WWW" | sudo bash -c 'cat > /etc/apache2/sites-available/www.$(WWW_SITE).conf'
	sudo a2ensite $(WWW_SITE) www.$(WWW_SITE)
	sudo a2enmod rewrite expires
	sudo apachectl configtest
	sudo service apache2 reload



# target: virtual-host-https - Create entries for the virtual host https.
.PHONY: virtual-host-https

define VIRTUAL_HOST_443
Define site $(WWW_SITE)
ServerAdmin $(SERVER_ADMIN)

<VirtualHost *:80>
	ServerName $${site}
	Redirect "/" "https://$${site}/"
</VirtualHost>

<VirtualHost *:443>
	Include $(SSL_APACHE_CONF)
	SSLCertificateFile 		$(SSL_PEM_BASE)/cert.pem
	SSLCertificateKeyFile 	$(SSL_PEM_BASE)/privkey.pem
	SSLCertificateChainFile $(SSL_PEM_BASE)/chain.pem

	ServerName $${site}
	DocumentRoot $(HTDOCS_BASE)/$${site}/htdocs

	<Directory />
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
		Order allow,deny
		Allow from all
	</Directory>

	<FilesMatch "\.(jpe?g|png|gif|js|css|svg|ttf|otf|eot|woff|woff2|ico)$">
		ExpiresActive On
		ExpiresDefault "access plus 1 week"
	</FilesMatch>

	ErrorLog  $(HTDOCS_BASE)/$${site}/error.log
	CustomLog $(HTDOCS_BASE)/$${site}/access.log combined
</VirtualHost>
endef
export VIRTUAL_HOST_443

define VIRTUAL_HOST_443_WWW
Define site $(WWW_SITE)
ServerAdmin $(SERVER_ADMIN)

<VirtualHost *:80>
	ServerName www.$${site}
	Redirect "/" "https://www.$${site}/"
</VirtualHost>

<VirtualHost *:443>
	Include $(SSL_APACHE_CONF)
	SSLCertificateFile 		$(SSL_PEM_BASE)/cert.pem
	SSLCertificateKeyFile 	$(SSL_PEM_BASE)/privkey.pem
	SSLCertificateChainFile $(SSL_PEM_BASE)/chain.pem

	ServerName www.$${site}
	Redirect "/" "https://$${site}/"
</VirtualHost>
endef
export VIRTUAL_HOST_443_WWW

virtual-host-https:
	echo "$$VIRTUAL_HOST_443" | sudo bash -c 'cat > /etc/apache2/sites-available/$(WWW_SITE).conf'
	echo "$$VIRTUAL_HOST_443_WWW" | sudo bash -c 'cat > /etc/apache2/sites-available/www.$(WWW_SITE).conf'
	sudo a2enmod ssl
	sudo apachectl configtest
	sudo service apache2 reload
