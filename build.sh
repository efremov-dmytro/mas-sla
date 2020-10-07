#!/bin/bash
docker-compose down
sudo chmod 777 -R ./slave/data/*
sudo chmod 777 -R ./master/data/*
rm -rf ./master/data/*
rm -rf ./slave/data/*
docker-compose build
docker-compose up -d
until docker exec master sh -c 'export MYSQL_PWD=Babina_; mysql -u root -e ";"'
do
    echo "Waiting for _master database connection..."
    sleep 5
done

priv_stmt='GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; FLUSH PRIVILEGES;'
docker exec master sh -c "export MYSQL_PWD=Babina_; mysql -u root -e '$priv_stmt'"

until docker-compose exec slave sh -c 'export MYSQL_PWD=Babina_; mysql -u root -e ";"'
do
    echo "Waiting for _slave database connection..."
    sleep 5
done

dip() {
#     docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

MS_STATUS=`docker exec master sh -c 'export MYSQL_PWD=Babina_; mysql -u root -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

#start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(dip master)',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE=$CURRENT_LOG,MASTER_LOG_POS=$CURRENT_POS;START SLAVE;"
start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(dip master)',MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd';START SLAVE;"
start_slave_cmd='export MYSQL_PWD=Babina_; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
docker exec slave sh -c "$start_slave_cmd"

docker exec slave sh -c "export MYSQL_PWD=Babina_; mysql -u root -e 'SHOW SLAVE STATUS \G'"
