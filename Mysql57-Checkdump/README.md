Main script is in checking/CHECK_TABLE.sh
By default, it use username 'test' and password 'test' for MySQL connections.
Run sed -i "s/-utest -ptest/-uYOUR_USERNAME -pYOUR_PASSWORD/g" checking/CHECK_TABLE.sh and use your user:password settings.

Script works only with .gz files, so you must put them in dumps/ directory.

After run, you can find log file in dumpcheck directory.
