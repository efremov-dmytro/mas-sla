#!/bin/bash
docker-compose down
sudo chmod 777 -R ./slave1/data/*
sudo chmod 777 -R ./slave2/data/*
sudo chmod 777 -R ./master/data/*
rm -rf ./master/data/*
rm -rf ./slave1/data/*
rm -rf ./slave2/data/*
sudo chmod 644 -R ./slave1/conf/*
sudo chmod 644 -R ./slave2/conf/*
sudo chmod 644 -R ./master/conf/*
docker-compose build
docker-compose up -d
#-----------------------------------------------------------------------------------------------------------------
echo "Connection to DB MASTER"

until docker exec master sh -c 'export MYSQL_PWD=Babina_; mysql -u root -h 127.0.0.1 -pBabina_ -e ";"'
do
    sleep 10
    echo "Waiting for _master database connection..."
    sleep 2
done
#-----------------------------------------------------------------------------------------------------------------
echo "grant replication slave on master"

master_stmt='GRANT REPLICATION SLAVE ON *.* TO "mydb_slave_user"@"%" IDENTIFIED BY "mydb_slave_pwd"; FLUSH PRIVILEGES;'
docker exec master sh -c "export MYSQL_PWD=Babina_; mysql -u root -h 127.0.0.1 -pBabina_ -e '$master_stmt'"
#-----------------------------------------------------------------------------------------------------------------
echo "Connection to DB SLAVE1"

until docker-compose exec slave1 sh -c 'export MYSQL_PWD=Babina_; mysql -u root -h 127.0.0.1 -pBabina_ -e ";"'
do
    echo "Waiting for _slave database connection..."
    sleep 2
done
#-----------------------------------------------------------------------------------------------------------------
echo "Connection to DB SLAVE2"

until docker-compose exec slave2 sh -c 'export MYSQL_PWD=Babina_; mysql -u root -h 127.0.0.1 -pBabina_ -e ";"'
do
    echo "Waiting for _slave2 database connection..."
    sleep 2
done
#-----------------------------------------------------------------------------------------------------------------
dip() {
#     docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
    docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

MS_STATUS=`docker exec master sh -c 'export MYSQL_PWD=Babina_; mysql -u root -h 127.0.0.1 -pBabina_ -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`
echo "MASTER_IP=$(dip master)"
echo "CURRENT_LOG=$CURRENT_LOG"
echo "CURRENT_POS=$CURRENT_POS"
#-----------------------------------------------------------------------------------------------------------------
#command for slave1
start_slave_stmt="CHANGE MASTER TO MASTER_HOST='$(dip master)',MASTER_DELAY = 3600,MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS;START SLAVE;"
start_slave_cmd='export MYSQL_PWD=Babina_; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'
#-----------------------------------------------------------------------------------------------------------------
#command for slave2
start_slave2_stmt="CHANGE MASTER TO MASTER_HOST='$(dip master)',MASTER_DELAY = 21600,MASTER_USER='mydb_slave_user',MASTER_PASSWORD='mydb_slave_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS;START SLAVE;"
start_slave2_cmd='export MYSQL_PWD=Babina_; mysql -u root -e "'
start_slave2_cmd+="$start_slave2_stmt"
start_slave2_cmd+='"'
#-----------------------------------------------------------------------------------------------------------------
echo "start slave1"
docker exec slave1 sh -c "$start_slave_cmd"
echo "slave1 status"
docker exec slave1 sh -c "export MYSQL_PWD=Babina_; mysql -u root -e 'SHOW SLAVE STATUS \G'"

#-----------------------------------------------------------------------------------------------------------------
echo "start slave2"
docker exec slave2 sh -c "$start_slave2_cmd"
echo "slave2 status"
docker exec slave2 sh -c "export MYSQL_PWD=Babina_; mysql -u root -e 'SHOW SLAVE STATUS \G'"
#-----------------------------------------------------------------------------------------------------------------
SL1_SQL_delay_STATUS=`docker exec slave1 sh -c 'export MYSQL_PWD=Babina_; mysql -u root -e "SHOW SLAVE STATUS \G"' | grep SQL_Delay`
SL2_SQL_delay_STATUS=`docker exec slave2 sh -c 'export MYSQL_PWD=Babina_; mysql -u root -e "SHOW SLAVE STATUS \G"' | grep SQL_Delay`
echo "SLAVE1 DELAY=$SL1_SQL_delay_STATUS"
echo "SLAVE2 DELAY=$SL2_SQL_delay_STATUS"
