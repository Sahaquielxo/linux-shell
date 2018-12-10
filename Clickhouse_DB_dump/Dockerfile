FROM python:3.6
COPY art.repo /etc/yum.repos.d/
RUN yum -y install clickhouse-client
RUN pip3 install clickhouse-driver boto3 requests click statsd
COPY s3 /usr/local/bin/
RUN chmod +x /usr/local/bin/s3
ENV LC_ALL ru_RU.utf8
ENV LANG ru_RU.utf8
ENV AWS_ACCESS_KEY_ID xxxx
ENV AWS_SECRET_ACCESS_KEY yyyy
ENV S3_URL https://zzzz.store.com
CMD ["tail", "-f", "/bin/bash"]

