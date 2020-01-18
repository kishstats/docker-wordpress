#!/bin/bash

usage () { echo "Usage : $0 -w <wordpress instance name>"; }

while getopts ":w:h:c" opt; do
  case $opt in
    w)
      INSTANCE_NAME=$OPTARG
      DATABASE_NAME="wp_$INSTANCE_NAME"
      ;;
    h) usage; exit 1;;
    c) 
      echo "cache flag set"; can_use_cache=true;;
    \?)
      echo "Invalid option: -$OPTARG" >&2; usage; exit 1;;
    :)
      echo "Option -$OPTARG requires an argument." >&2; usage; exit 1;;
    *) 
      echo "Unimplemented option: -$OPTARG" >&2; usage; exit 1;;
  esac
done

remove_instance () {
    echo "dropping instance: $INSTANCE_NAME"

    path="./wordpress/$INSTANCE_NAME"
    rm -rf $path

    DATABASE_NAME="wp_$INSTANCE_NAME"
    echo "dropping database: $DATABASE_NAME"
    docker exec -it wp-mysql mysql -u root -proot --execute="DROP DATABASE IF EXISTS $DATABASE_NAME"
}

remove_all () {
    read -p "Are you sure you want to remove all instances? (Enter \"y\" to continue): " can_remove_all

    if [ "$can_remove_all" = "y" ]
    then
        echo "removing all instances"

        INSTANCES=$(find ./wordpress -maxdepth 1 -mindepth 1 -type d)

        for path in $INSTANCES
        do 
            instance=${path:12}

            if [ ! $instance = "wordpress" ] 
            then 
                echo "dropping instance: $instance"

                rm -rf $path

                database_name="wp_$instance"
                echo "dropping database: $database_name"
                docker exec -it wp-mysql mysql -u root -proot --execute="DROP DATABASE IF EXISTS $database_name"
            fi
        done
    else
        echo "no action taken"
    fi
}

if [ ! "$INSTANCE_NAME" ]
then
    echo "no instance name set"
    remove_all
else
    echo "instance name set"
    remove_instance
fi
