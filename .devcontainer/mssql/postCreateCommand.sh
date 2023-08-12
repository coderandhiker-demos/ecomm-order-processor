#!/bin/bash
SApassword=$1
dacpath=$2
sqlpath=$3

echo "SELECT * FROM SYS.DATABASES" | dd of=testsqlconnection.sql
for i in {1..60};
do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SApassword -d master -i testsqlconnection.sql > /dev/null
    if [ $? -eq 0 ]
    then
        echo "SQL server ready"
        break
    else
        echo "Not ready yet..."
        sleep 1
    fi
done
rm testsqlconnection.sql



echo "Installing SQL Files"
for f in $sqlpath/*
do
    if [[ "$f" == *.sql ]];
    then
        echo "Executing $f"
        /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SApassword -d master -i $f
    fi
done