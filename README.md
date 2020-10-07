mysql-replication

start script:	

./build.sh

if mysql: [Warning] World-writable config file '/etc/mysql/conf.d/mysql.conf.cnf' is ignored.	

change permissions to mysql.conf.cnf to 644

how to check:

make change to master database

example: 

docker exec master sh -c "export MYSQL_PWD=Babina_; mysql -u root mydb -e 'create table test_mysq(test_mysq int); insert into test_mysq values (38093), (2417648)'"

Chcek this changes in slave database

exapmle:

docker exec slave sh -c "export MYSQL_PWD=Babina_; mysql -u root mydb -e 'select * from test_mysq \G'"

If have something troubleshooting run docker-compose logs and run ./build.sh 


check master db

docker exec master sh -c 'mysql -u root -pBabina_ -e "SHOW MASTER STATUS \G"'

check slave db 

docker exec slave sh -c 'mysql -u root -pBabina_ -e "SHOW SLAVE STATUS \G"'
