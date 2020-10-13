#!/bin/bash
echo "What do you want to name the table?"
read db_table
echo "ok i will create a base named $db_table"
read -p "What type database you want? (varchar/int)" db_type
case $db_type in
#char) read -p "what char? (10/20)" char_type 
#case $char_type in
#10) echo "ok we use 10 symbols" ;;
#20) echo " ok we use 20 symbols";;
#esac
varchar) echo "ok we use text type"
db_type=$db_type"(255)";;
int) echo "ok we use int type ";;
esac
#db_type=$db_type+"(255)"
echo "$db_type"
echo "Insert six table field"
read field1
read field2
read field3
read field4
read field5
read field6
echo "Insert six table value"
read value1
read value2
read value3
read value4
read value5
read value6
read -p "do you want create table $db_table with type $db_type with value $value? (y/n)" answer
case $answer in
y) echo "ok let's do it" 
if [ $db_type = "int" ];then
docker exec master sh -c "export MYSQL_PWD=Babina; mysql -u root -h 127.0.0.1 -pBabina_ mydb -e 'create table if not exists $db_table ($field1 $db_type, $field2 $db_type, $field3 $db_type, $field4 $db_type, $field5 $db_type, $field6 $db_type); insert into $db_table value ($value1, $value2, $value3, $value4, $value5, $value6)'"
else
insert="INSERT INTO $db_table ($field1, $field2, $field3, $field4, $field5, $field6) VALUES ('$value1', '$value2', '$value3', '$value4', '$value5', '$value6')"
master_con1="'"
master_con='export MYSQL_PWD=Babina_; mysql -u root -h 127.0.0.1 -pBabina_ mydb -e "create table '$db_table'('$field1' '$db_type', '$field2' '$db_type', '$field3' '$db_type', '$field4' '$db_type', '$field5' '$db_type', '$field6' '$db_type'); '$insert' ;"'
#master_con="$insert"
#master_con1="'"
docker exec master sh -c "$master_con"
echo "$master_con"
fi
;;
n) echo "ok? maybe another time we end this ";;
esac
docker exec master sh -c "export MYSQL_PWD=Babina; mysql -u root -h 127.0.0.1 -pBabina_ mydb -e 'select * from $db_table \G'"
