### Mysql-replication 

# start script:	

./build.sh

# how to check:

make change to master database

_example:_ 

**_docker exec master sh -c "export MYSQL_PWD=Babina_; mysql -u root mydb -e 'create table test_mysq(test_mysq int); insert into test_mysq values (38093), (2417648)'"_**

Chcek this changes in slave database

_exapmle:_

**_docker exec slave sh -c "export MYSQL_PWD=Babina_; mysql -u root mydb -e 'select * from test_mysq \G'"_**

# If have something troubleshooting
_run docker-compose logs and run ./build.sh 

_if mysql: [Warning] World-writable config file '/etc/mysql/conf.d/mysql.conf.cnf' is ignored.	
_change permissions to mysql.conf.cnf to 644 (master(slave)/conf)

# check master db

**_docker exec master sh -c 'mysql -u root -pBabina_ -e "SHOW MASTER STATUS \G"'_**

# check slave db 

**_docker exec slave sh -c 'mysql -u root -pBabina_ -e "SHOW SLAVE STATUS \G"'
