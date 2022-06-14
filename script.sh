#!/bin/bash
yum -y update
yum -y install httpd

printf '
<html>
<head>
        <title>Terraform</title>
</head>
<body bgcolor=yellow>
        <p style="color: red; text-align: center; font-size: 70px;">Hello World from Pipiline!</p>
</body>
</html>
' >> /var/www/html/index.html
sudo service httpd start
chkconfig httpd on