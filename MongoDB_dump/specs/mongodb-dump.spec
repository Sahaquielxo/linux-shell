
%global _topdir %(pwd)/rpmbuild
%global _builddir .
%global _sourcedir %{_builddir}
%global package_version %{git_tag}

Name:           mongodb-dump
Version:        %{package_version}
Release:        1%{?dist}
Summary:        MongoDB Dumpber

Group:          Development/Languages
License:        (c) Rambler&Co
URL:            https://gitlab.xxx.com/db-dump-tools
BuildArch:      noarch

Requires:       s3fs-fuse
Requires:	awscli
Requires:	pushgateway
Requires:	jq


%systemd_requires

%description
%{summary}

%prep
%{__mkdir_p} %{_topdir}/{RPMS/noarch,SRPMS}


%install
%{__mkdir_p} %{buildroot}/root/.aws
%{__mkdir_p} %{buildroot}/etc/cron.d
%{__mkdir_p} %{buildroot}/var/log/mongodb-dump
touch %{buildroot}/root/.passwd-s3fs
touch %{buildroot}/root/.aws/config
touch %{buildroot}/root/.aws/credentials
echo "${aws_access_key_id}:${aws_secret_access_key}" >> %{buildroot}/root/.passwd-s3fs
echo -e '[default]\ns3 = \n  multipart_chunksize = 512MB' >> %{buildroot}/root/.aws/config
echo "[default]" >> %{buildroot}/root/.aws/credentials
echo "aws_access_key_id = ${aws_access_key_id}" >> %{buildroot}/root/.aws/credentials
echo "aws_secret_access_key = ${aws_secret_access_key}" >> %{buildroot}/root/.aws/credentials
echo -e 's3 = \n  multipart_chunksize = 512MB' >> %{buildroot}/root/.aws/credentials
%{__install} -D shells/mongodb-dump.sh %{buildroot}/usr/local/bin/mongodb-dump.sh
%{__install} -D shells/mongodb-metrics.sh %{buildroot}/usr/local/bin/mongodb-metrics.sh
%{__install} -D shells/mongodb-pushgatesend.sh %{buildroot}/usr/local/bin/mongodb-pushgatesend.sh
%{__install} -D configs/mongo-dump.crontab %{buildroot}/etc/cron.d/mongo-dump.crontab

%files
%defattr(644,root,root,755)
%attr(755,root,root) /usr/local/bin/mongodb-dump.sh
%attr(755,root,root) /usr/local/bin/mongodb-metrics.sh
%attr(755,root,root) /usr/local/bin/mongodb-pushgatesend.sh
%dir /root/.aws
%dir /var/log/mongodb-dump
%attr(600,root,root) /root/.passwd-s3fs
%attr(600,root,root) /root/.aws/config
%attr(600,root,root) /root/.aws/credentials
/etc/cron.d/mongo-dump.crontab

%post
systemctl enable pushgateway
systemctl start pushgateway
