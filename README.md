# Docker WordPress 

Download, install, and run multiple instances of WordPress using a single Docker Compose configuration.

Note: this implementation is for special use cases only. If your needs consist of running a single instance of WordPress in a local environment, there are better alternatives available.

## Create New WordPress Instance 

```bash
sh get_wordpress.sh -w <instance name>
```

### Create New WordPress Instance from Cache

Passing the `-c` option will use the same version of WordPress that was previously downloaded. This will avoid the need to keep downloading WordPress each time a new instance is setup. 

```bash
sh get_wordpress.sh -w <instance name> -c
```

### Create New Instance Using Specific WordPress Version

```bash
sh get_wordpress.sh -w <instance name> -v <version> -c
```

### Create New Instance Using Custom Domain

Use a custom domain like `example.local`. Note: you will also have to add your domain name to your system's hosts file. 

```bash
sudo sh get_wordpress.sh -w <instance name> -d <custom domain>
```

## WordPress URL
- https://wordpress.org/latest.zip

## Access Docker Containers

### Access Via Terminal

```bash
docker exec -it wp-webserver sh
docker exec -it wp-php-fpm bash
docker exec -it wp-mysql bash
```

### Show MySQL Databases 

```bash
docker exec -it wp-mysql mysql -u root -proot --execute="SHOW DATABASES;"
```

## Drop WordPress Instances 

### Drop a Single Instance Only

```bash
sh drop_instances.sh -w <instance name>
```

### Drop ALL Instances

```bash
sh drop_instances.sh
```