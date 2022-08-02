create user 'reformulator'@'localhost' identified by 'passMe';
GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'reformulator'@'localhost' WITH GRANT OPTION;

alter user 'root'@'localhost' identified with mysql_native_password by 'passMe';
alter user 'reformulator'@'localhost' identified with mysql_native_password by 'passMe';
flush privileges;

create database employeetracker;
create database employeetracker10;
create database employeetracker100;
create database employeetracker1000;

create database wall;
create database wall10;
create database wall100;
create database wall1000;