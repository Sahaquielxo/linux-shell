# db-dump-tools

**shells/mongodb-dump.sh**
Делает резервную копию, отправляет в S3 storage.

**shells/mongodb-metrics.sh**
Собирает метрики для отправки в Prometheus и построения dashboards.

**shells/mongodb-pushgatesend.sh**
Отправляет метрики в Prometheus.


# How to use:

1. Установить пакет: 

`yum -y install rambler-crm-mongodb-dump`

2. Готово.


# Описание пакета

*1. Зависимости:*

 - awscli
 - pushgateway
 - s3fs-fuse

*2. Файлы установки:*

 - /etc/cron.d/mongo-dump.crontab 

crontab-файл, определяющий ротацию запуска дампа и отправки метрик:


```
0 10 * * * root /bin/bash /usr/local/bin/mongodb-dump.sh
*/2 * * * * root /bin/bash /usr/local/bin/mongodb-pushgatesend.sh
```


 - /root/.aws/config
 - /root/.aws/credentials

Файлы, определяющие конфигурацию aws cli.

 - /root/.passwd-s3fs

Файл, определяющий конфигурацию s3fs.

 - /usr/local/bin/mongodb-dump.sh

Создает резервную копию MongoDB, срабатывает только если текущий сервер в состоянии Secondary.

 - /usr/local/bin/mongodb-metrics.sh

Собирает метрики для построение графиков в Grafana:

```
CRM_Buckets_Count - количество бакетов в S3;
CRM_Last_Bucket_Size - размер последней резервной копии;
CRM_Last_Bucket_Files_Count - количество файлов (заданный размер - 100Mb) на которые разбита резервная копия;
CRM_Last_Bucket_Create_Date_Timestamp - дата создания последней копии MongoDB;
CRM_Last_Mongodump_Duration - продолжительность создания резервной копии, в секундах.
```


 - /usr/local/bin/mongodb-pushgatesend.sh

Отправляет собранные метрики в pushgateway.