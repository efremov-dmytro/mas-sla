### Mysql-replication 

# start script:	

./build.sh

# how to check:

make change to master database

_example:_ 

_you can use script ./test.sh_

**_docker exec master sh -c "export MYSQL_PWD=Babina_; mysql -u root mydb -e 'create table test_mysq(test_mysq int); insert into test_mysq values (38093), (2417648)'"**

Chcek this changes in slave database

_exapmle:_

**_docker exec slave1 sh -c "export MYSQL_PWD=Babina_; mysql -u root mydb -e 'select * from test_mysq \G'"**

**_docker exec slave2 sh -c "export MYSQL_PWD=Babina_; mysql -u root mydb -e 'select * from test_mysq \G'"**

# If have something troubleshooting
_run docker-compose logs and rerun ./build.sh_

_if mysql: [Warning] World-writable config file '/etc/mysql/conf.d/mysql.conf.cnf' is ignored._	
_change permissions to mysql.conf.cnf to 644 (master(slave)/conf)_ [UPD - fix this trouble]

# check master db

**_docker exec master sh -c 'mysql -u root -pBabina_ -e "SHOW MASTER STATUS \G"'**

# check slave db 

**_docker exec slave1 sh -c 'mysql -u root -pBabina_ -e "SHOW SLAVE STATUS \G"'**

**_docker exec slave2 sh -c 'mysql -u root -pBabina_ -e "SHOW SLAVE STATUS \G"'**

# check slave SQL_Delay


**docker exec slave1 sh -c "export MYSQL_PWD=Babina_; mysql -u root -e 'SHOW SLAVE STATUS \G'" | grep SQL_Delay**

**docker exec slave2 sh -c "export MYSQL_PWD=Babina_; mysql -u root -e 'SHOW SLAVE STATUS \G'" | grep SQL_Delay**
