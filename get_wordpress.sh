#!/bin/bash

VERSION=latest
DOWNLOAD_URL=https://wordpress.org/latest.zip
DOWNLOADED_ZIPFILE=latest.zip

can_use_cache=false

usage () { echo "Usage : $0 -w <wordpress instance name>"; }

while getopts ":w:h:v:d:c" opt; do
  case $opt in
    w)
      INSTANCE_NAME=$OPTARG
      DATABASE_NAME="wp_$INSTANCE_NAME"
      ;;
    h) usage; exit 1;;
    c) 
      echo "cache flag set"; can_use_cache=true;;
    v)
      VERSION=$OPTARG
      echo "specific version specified: $VERSION" 

      # example url: https://wordpress.org/wordpress-5.0.8.zip
      DOWNLOAD_URL=https://wordpress.org/wordpress-$VERSION.zip
      DOWNLOADED_ZIPFILE=wordpress-$VERSION.zip
      ;;
    d) 
      CUSTOM_DOMAIN=$OPTARG
      echo "custom domain specified: $CUSTOM_DOMAIN"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2; usage; exit 1;;
    :)
      echo "Option -$OPTARG requires an argument." >&2; usage; exit 1;;
    *) 
      echo "Unimplemented option: -$OPTARG" >&2; usage; exit 1;;
  esac
done

if [ ! "$INSTANCE_NAME" ]
then
    echo "Instance name is required." >&2
    usage
    exit 1
fi

mkdir -p ./wordpress

if [[ "$can_use_cache" = "false" || ! -f "./wordpress/$DOWNLOADED_ZIPFILE" ]]; then 
    echo "downloading WordPress"
    wget -O ./wordpress/$DOWNLOADED_ZIPFILE $DOWNLOAD_URL
else
    echo "skipping new download"
fi

mkdir ./wordpress/$INSTANCE_NAME

echo "name:"
echo $INSTANCE_NAME
unzip ./wordpress/$DOWNLOADED_ZIPFILE -d ./wordpress
INSTANCE_PATH=./wordpress/$INSTANCE_NAME
mv ./wordpress/wordpress/* $INSTANCE_PATH

echo "creating database:"
echo $DATABASE_NAME
docker exec -it wp-mysql mysql -u root -proot --execute="CREATE DATABASE IF NOT EXISTS $DATABASE_NAME"

echo "creating wp-config.php"
touch $INSTANCE_PATH/wp-config.php

cat >$INSTANCE_PATH/wp-config.php <<EOL
<?php

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '${DATABASE_NAME}' );

/** MySQL database username */
define( 'DB_USER', 'root' );

/** MySQL database password */
define( 'DB_PASSWORD', 'root' );

/** MySQL hostname */
define( 'DB_HOST', 'mysql' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 * Local DEV only - not concerned about this
 * @since 2.6.0
 */
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
\$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define( 'WP_DEBUG', true );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
EOL


if [ "$CUSTOM_DOMAIN" ]
then
    
echo "Setting up Custom Domain."

vhosts_path=phpdocker/nginx/vhosts

mkdir -p $vhosts_path

cat >$vhosts_path/$INSTANCE_NAME.conf <<EOL
server {
    listen    80;
    server_name  $CUSTOM_DOMAIN;
    root   /application/$INSTANCE_NAME;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php-fpm:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PHP_VALUE "error_log=/var/log/nginx/application_php_errors.log";
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        include fastcgi_params;
    }
}
EOL

echo "Custom domain added"


echo "IMPORTANT! Don't forget to add your custom domain to your hosts file:"
echo "127.0.0.1 $CUSTOM_DOMAIN"

# would require root access to automate
# echo "127.0.0.1 $CUSTOM_DOMAIN" >> /etc/hosts

# restart webserver container
docker-compose restart webserver

else
    echo "No Custom Domain set."
fi

echo "DONE"