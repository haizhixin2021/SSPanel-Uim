#!/usr/bin/bash

cat << "EOF"
SSPanel-UIM update script
Author: M1Screw
Github: https://github.com/sspanel-uim/SSPanel-Uim-Dev
Usage: 
./update.sh dev --> Upgrade to the latest development version
./update.sh dev-20230530 --> Upgrade to the latest development version
./update.sh release $release_version $db_version --> Upgrade to the release version with the specified database version
EOF

[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script!"; exit 1; }

do_update_sspanel_dev(){
    git pull origin dev
    git reset --hard origin/dev
    git fetch --prune --prune-tags
    rm -r storage/framework/smarty/compile/*
    php composer.phar install --no-dev
    php composer.phar selfupdate
    php xcat Update
    php xcat Tool importAllSettings
    php xcat Migration latest
}

do_update_sspanel_dev_20230530(){
    git pull
    rm -r storage/framework/smarty/compile/*
    php composer.phar install --no-dev --ignore-platform-req=ext-zip --ignore-platform-req=ext-fileinfo
    php composer.phar selfupdate
    chmod -R 755 /www/wwwroot/sspanel.880219.xyz/sspanel-uim
    chown -R www:www /www/wwwroot/sspanel.880219.xyz/sspanel-uim
    php xcat Update
    php xcat Tool importAllSettings
    php xcat Migration latest
}

do_update_sspanel_release(){
    tag=$1
    db_version=$2
    git pull --tags
    git reset --hard $tag
    rm -r storage/framework/smarty/compile/*
    php composer.phar install --no-dev
    php composer.phar selfupdate
    php xcat Update
    php xcat Tool importAllSettings
    php xcat Migration $db_version
}

if [[ $1 == "dev" ]]; then
    do_update_sspanel_dev
    exit 0
fi

if [[ $1 == "dev-20230530" ]]; then
    do_update_sspanel_dev_20230530
    exit 0
fi

if [[ $1 == "release" ]]; then
    if [[ $2 == "" ]]; then
        echo "Error: The release version cannot be empty!"
        exit 1
    fi
    if [[ $3 == "" ]]; then
        echo "Error: The database version cannot be empty!"
        exit 1
    fi
    do_update_sspanel_release $2 $3
    exit 0
fi
