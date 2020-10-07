MS_STATUS=`docker exec master sh -c 'export MYSQL_PWD=Babina_; mysql -u root -h 127.0.0.1 -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`
