#!/bin/bash -x

# Setup apache for SAXS
echo "Configuring Apache"
rm -f /etc/httpd/conf.d/*.conf
cat > /etc/httpd/conf.d/saxs.conf << EOF
DocumentRoot	/var/www/saxs
Alias /static /var/www/saxs/app/static
ScriptAlias / /var/www/saxs/run.cgi/

<Directory /var/www/saxs>
    Options +ExecCGI
    AddHandler cgi-script .cgi
    SetEnv  HTTP_EPPN john.hacker@somewhere.com
    SetEnv  HTTP_CN "John Hacker"
    SetEnv  HTTP_MAIL john.hacker@somewhere.com
</Directory>
EOF

adduser saxs
usermod -G saxs,apache apache
usermod -G saxs,apache saxs

# Setup SAXS portal application
echo  "Setting up web interface"
tar xvzf /tmp/saxs-portal.tar.gz -C /var/www
chown -R apache:saxs /var/www/saxs
cd /var/www/saxs
virtualenv flask
source flask/bin/activate
pip install -r requirements.txt &>/dev/null

# Setup SAXS portal database with one default user
echo  "Configuring database"
mkdir -p /var/www/SaxsExperiments/1
python /var/www/saxs/db_create.py
sqlite3 /var/www/SaxsExperiments/app.db "insert into users values (1,'John Hacker','john.hacker@somewhere.com','john.hacker@somewhere.com',1,1);"

sed -i 's/Group apache/Group saxs/' /etc/httpd/conf/httpd.conf
chown -R apache:saxs /var/www/SaxsExperiments

#mkdir ~saxs/.ssh
#ctx download-resource resources/ssh/id_rsa_saxs.pub '@{"target_path": "/tmp/id_rsa_saxs.pub"}'
#cat /tmp/id_rsa_saxs.pub >>~saxs/.ssh/authorized_keys

#chown -R saxs ~saxs/.ssh
#chmod 700 ~saxs/.ssh
#chmod 600 ~saxs/.ssh/authorized_keys

# Install server-side scripts
echo  "Setting up submission server"
tar -xvzf /tmp/saxs-server.tar.gz -C /

# Setup syslog for SAXS
echo "local7.* /var/log/saxs.log" > /etc/rsyslog.d/30-saxs.conf
systemctl restart rsyslog

# Restart apache
systemctl restart httpd
